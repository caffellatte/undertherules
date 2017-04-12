#
# followers https://www.instagram.com/graphql/query/?query_id=17851374694183129&id=4254944257&first=10&after=AQBazNnszkJeoUs9GzlpVn5GMSHHruookJzZlzzyTsmtQ4uG3H5GL_cXfIGCarRN3aK9UVZy3rMSj8nsdXPaL9izICMVJjr3U1qQylGSf_2RVQ
#     
# following https://www.instagram.com/graphql/query/?query_id=17874545323001329&id=4254944257&first=10&after=AQBYiZu0MazTlpYRYxF4zxXNsGkdTcjVnJ6gekN4oRiJMqCsL9UZ-Udj5SzWTzM9JuDjlvIzNjMjNhsRmOtjyEl7rqFqIGUMkEYHnSLFg6b4qg

# cluster.coffee

# Modules
_           = require('lodash')
fs          = require('fs-extra')
os          = require('os')
kue         = require('kue')
pug         = require('pug')
url         = require('url')
http        = require('http')
shoe        = require('shoe')
dnode       = require('dnode')
level       = require('levelup')
crypto      = require('crypto')
stylus      = require('stylus')
natural     = require('natural')
cluster     = require('cluster')
request     = require('request')
coffeeify   = require('coffeeify')
browserify  = require('browserify')
levelgraph  = require('levelgraph')
querystring = require('querystring')
igSegment   = require('instagram-id-to-url-segment')
igAccount   = require('instagram-scrape-account-stats')

# Texts
helpText = '''
  /help - List of commands
  /about - Contacts & links
  /tokens - Add social network'''
startText = '''
  Flexible environment for social network analysis (SNA).
  Software provides full-cycle of retrieving and subsequent
  processing data from the social networks.
  Usage: /help. Contacts: /about.'''
aboutText = '''
  Undertherules, MIT license
  Copyright (c) 2016 Mikhail G. Lutsenko
  Github: https://github.com/caffellatte
  Npm: https://www.npmjs.com/~caffellatte
  Telegram: https://telegram.me/caffellatte'''
tokenText = '''
  Authorization via Social Networks'''

# Functions
{exec} = require('child_process')
{writeFileSync, readFileSync} = fs
{getAccountStats} = igAccount
{removeSync, mkdirsSync, copySync, ensureDirSync} = fs
{instagramIdToUrlSegment, urlSegmentToInstagramId} = igSegment
# Environment
numCPUs = require('os').cpus().length
{KUE_PORT, KUE_HOST, PANEL_PORT, PANEL_HOST} = process.env
{CORE_DIR, LEVEL_DIR, STATIC_DIR, HTDOCS_DIR, VK_SCOPE} = process.env
{VK_CLIENT_ID, VK_CLIENT_SECRET, VK_DISPLAY, VK_VERSION} = process.env
VK_REDIRECT_HOST = PANEL_HOST
VK_REDIRECT_PORT = PANEL_PORT

# Files
browserCoffee     = "#{HTDOCS_DIR}/browser.coffee"
clusterCoffee     = "#{CORE_DIR}/cluster.coffee"
staticImg         = "#{STATIC_DIR}/img"
staticFaviconIco  = "#{STATIC_DIR}/favicon.ico"
indexHtml         = "#{STATIC_DIR}/index.html"
styleCss          = "#{STATIC_DIR}/style.css"
bundleJs          = "#{STATIC_DIR}/bundle.js"
htdocsImg         = "#{HTDOCS_DIR}/img"
htdocsFaviconIco  = "#{HTDOCS_DIR}/img/favicon.ico"
templatePug       = "#{HTDOCS_DIR}/template.pug"
styleStyl         = "#{HTDOCS_DIR}/style.styl"

# Queue
queue = kue.createQueue()

#UnderTheRules
class UnderTheRules

  @tokenizer:new natural.RegexpTokenizer({pattern:/(https?:\/\/[^\s]+)/g})

  @dnodeSingUp:(guid, cb) ->
    if typeof cb isnt 'function'
      return
    createProfileJob = queue.create('createProfile', {
      title:"Create New Profile. GUID: #{guid}.",
      guid:guid
    }).save()
    createProfileJob.on('complete', (result) ->
      if result
        cb(null, result)
      else
        cb('ACCESS DENIED')
    )

  @dnodeSingIn:(id, cb) ->
    if typeof cb isnt 'function'
      return
    selectProfileJob = queue.create('selectProfile', {
      title:"Select Existed Profile. ID: #{id}.",
      id:id
    }).save()
    selectProfileJob.on('complete', (result) ->
      if result
        cb(null, result)
      else
        cb('ACCESS DENIED')
    )

  @createProfile:(job, done) ->
    {guid} = job.data
    if not guid?
      errorText = """Error! Can't create new profile.
        Timestamp: #{timestamp}, GUID: #{guid}"""
      return done(new Error(errorText))
    id = crypto.createHash('md5').update("#{guid}}").digest('hex')
    value = {
      id:id
      guid:guid
      timestamp:+new Date()
    }
    user.put(id, JSON.stringify(value), (err) ->
      if not err
        done(null, value)
      else
        done(new Error(err))
    )

  @selectProfile:(job, done) ->
    {id} = job.data
    user.get(id, (err, list) ->
      if err
        done(new Error(err))
      else
        if list
          done(null, JSON.parse(list))
        else
          done(new Error("Error! Type of list is '#{typeof list}'."))
    )

  @inputMessage:(id, msg, cb) ->
    switch msg
      when '/help' then cb(helpText)
      when '/start' then cb(startText)
      when '/about' then cb(aboutText)
      when '/tokens' then cb(tokenText)
      else
        mediaCheckerJob = queue.create('mediaChecker', {
          title:"Media Checker. ID: #{id}."
          id:id
          text:msg
        }).save()
        mediaCheckerJob.on('complete', (result) ->
          for item in result
            {path} = url.parse(item)
            getAccountStats({username:path[1..]}).then((account) ->
              console.log(account)
              {username,  name, userId, website} = account
              {isExplicit, isPrivate, isVerified} = account
              {description, followers, following, posts} = account
              cb(account.description)
            )
        )

  @mediaChecker:(job, done) ->
    {id, text} = job.data
    rawArray = UnderTheRules.tokenizer.tokenize(text)
    rawlinks = (url.parse(link) for link in rawArray)
    links    = (link.href for link in rawlinks when link.hostname?)
    done(null, links)

  @browserify:(job, done) ->
    {browserCoffee, bundleJs} = job.data
    bundle = browserify({extensions:['.coffee.md']})
    bundle.transform(coffeeify, {
      bare:false
      header:false
    })
    bundle.add(browserCoffee)
    bundle.bundle((error, js) ->
      throw error if error?
      writeFileSync(bundleJs, js)
      done()
    )

  @coffeelint:(job, done) ->
    {files} = job.data
    command = 'coffeelint ' + "#{files.join(' ')}"
    exec(command, (err, stdout, stderr) ->
      console.log(stdout, stderr)
      done()
    )

  @pugRender:(job, done) ->
    {templatePug, indexHtml} = job.data
    writeFileSync(indexHtml, pug.renderFile(templatePug, {pretty:true}))
    done()

  @static:(job, done) ->
    {htdocsFaviconIco, staticFaviconIco, htdocsImg, staticImg} = job.data
    mkdirsSync(job.data.STATIC_DIR)
    mkdirsSync("#{job.data.STATIC_DIR}/files")
    copySync(htdocsImg, staticImg)
    copySync(htdocsFaviconIco, staticFaviconIco)
    done()

  @stylusRender:(job, done) ->
    {styleStyl, styleCss} = job.data
    handler = (err, css) ->
      if err then throw err
      writeFileSync(styleCss, css)
    content = readFileSync(styleStyl, {encoding:'utf8'})
    stylus.render(content, handler)
    done()


# Master

if cluster.isMaster

## Kue
  kue.app.set('title', 'Under The Rules')
  kue.app.listen(KUE_PORT, KUE_HOST, ->
    console.log("Kue: http://#{KUE_HOST}:#{KUE_PORT}.")
    kue.Job.rangeByState('complete', 0, 100000, 'asc', (err, jobs) ->
      jobs.forEach((job) ->
        job.remove( -> return
        )
      )
    )
  )

## Ecstatic is a simple static file server middleware.
  ecstatic = require('ecstatic')(STATIC_DIR)
  server   = http.createServer(ecstatic) # Create a HTTP server.

## Starting Dnode. Using dnode via shoe & Install endpoint
  server.listen(PANEL_PORT, PANEL_HOST, ->
    console.log("Dnode: http://#{PANEL_HOST}:#{PANEL_PORT}")
  )
  sock = shoe((stream) -> # Define API object providing integration vith dnode
    d = dnode({
      dnodeSingUp:UnderTheRules.dnodeSingUp
      dnodeSingIn:UnderTheRules.dnodeSingIn
      sendCode:UnderTheRules.dnodeSendCode
      inputMessage:UnderTheRules.inputMessage
    })
    d.pipe(stream).pipe(d)
  )
  sock.install(server, '/dnode')

## Level. Initializing users, tokens
  # history = levelgraph(level(LEVEL_DIR + '/history'))
  ensureDirSync(LEVEL_DIR) # Create Level Dir folder
  log = level(LEVEL_DIR + '/log', {type:'json'})
  user = level(LEVEL_DIR + '/user', {type:'json'})
  token = level(LEVEL_DIR + '/token', {type:'json'})

  queue.process('createProfile', UnderTheRules.createProfile)
  queue.process('selectProfile', UnderTheRules.selectProfile)

## Create Jobs
  staticJob = queue.create('static', {
    title:'Copy images from HTDOCS_DIR to STATIC_DIR',
    STATIC_DIR:STATIC_DIR,
    htdocsFaviconIco:htdocsFaviconIco,
    staticFaviconIco:staticFaviconIco,
    htdocsImg:htdocsImg
    staticImg:staticImg
  }).save()

  staticJob.on('complete', ->
    queue.create('pugRender', {
      title:'Render (transform) pug template to html',
      templatePug:templatePug,
      indexHtml:indexHtml
    }).delay(1).save()

    queue.create('stylusRender', {
      title:'Render (transform) stylus template to css',
      styleStyl:styleStyl,
      styleCss:styleCss
    }).delay(1).save()

    queue.create('browserify', {
      title:'Render (transform) coffee template to js',
      browserCoffee:browserCoffee,
      bundleJs:bundleJs
    }).delay(1).save()

    queue.create('coffeelint', {
      title:'Link coffee files'
      files:[clusterCoffee, browserCoffee]
    }).delay(1).save() # browserCoffee
  )

## **Clean** job list on exit add to class
  exitHandler = (options, err) ->
    if err
      console.log(err.stack)
    if options.exit
      process.exit()
      return
    if options.cleanup
      removeSync(STATIC_DIR)

## Do something when app is closing or ctrl+c event or uncaught exceptions
  process.on('exit', exitHandler.bind(null, {cleanup:true}))
  process.on('SIGINT', exitHandler.bind(null, {exit:true}))
  process.on('uncaughtException', exitHandler.bind(null, {exit:true}))

  i = 1
  while i < numCPUs
    cluster.fork()
    i += 1
# Worker
else

  queue.process('coffeelint', UnderTheRules.coffeelint)
  queue.process('mediaChecker', UnderTheRules.mediaChecker)
  queue.process('static', UnderTheRules.static)
  queue.process('pugRender', UnderTheRules.pugRender)
  queue.process('stylusRender', UnderTheRules.stylusRender)
  queue.process('browserify', UnderTheRules.browserify)
