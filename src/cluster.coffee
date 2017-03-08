# cluster.coffee

# Modules
_           = require 'lodash'
fs          = require 'fs-extra'
os          = require 'os'
kue         = require 'kue'
pug         = require 'pug'
url         = require 'url'
http        = require 'http'
shoe        = require 'shoe'
dnode       = require 'dnode'
level       = require 'levelup'
crypto      = require 'crypto'
stylus      = require 'stylus'
natural     = require 'natural'
cluster     = require 'cluster'
request     = require 'request'
coffeeify   = require 'coffeeify'
browserify  = require 'browserify'
levelgraph  = require 'levelgraph'
querystring = require 'querystring'

# Functions
{exec} = require 'child_process'
{writeFileSync, readFileSync} = fs
{removeSync, mkdirsSync, copySync, ensureDirSync} = fs

# Environment
numCPUs = require('os').cpus().length
{KUE_PORT, PANEL_PORT, PANEL_HOST} = process.env
{CORE_DIR, LEVEL_DIR, STATIC_DIR, HTDOCS_DIR} = process.env
{VK_SCOPE, VK_REDIRECT_HOST, VK_REDIRECT_PORT} = process.env
{VK_CLIENT_ID, VK_CLIENT_SECRET, VK_DISPLAY, VK_VERSION} = process.env

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
coffeeFiles       = [browserCoffee, clusterCoffee]

# Queue
queue = kue.createQueue()

#UnderTheRules
class UnderTheRules
  @tokenizer: new natural.RegexpTokenizer({pattern:/(https?:\/\/[^\s]+)/g})
  @dnodeAuth: (_user, _pass, cb) ->
    if typeof cb isnt 'function'
      console.log "cb isnt 'function'"
      return
    if _user? and _pass?
      AuthUserJob = queue.create('authenticate',
        title: "Authenticate user. Telegram UID: #{_user}.",
        chatId: _user).save()
      AuthUserJob.on 'complete', (result) ->
        {user, pass, first_name, last_name} = result
        if +_user is +user and _pass is pass
          console.log "signed as: #{first_name} #{last_name}"
          cb null, result
        else
          cb 'ACCESS DENIED'
    else
       cb 'ACCESS DENIED'
  @dnodeSendCode: (s, cb) ->
    {chatId, code, network} = s
    sendCodeJob = queue.create('sendCode',
      title: "Send authorization code",
      chatId: chatId,
      code: code,
      network:network).save()
    sendCodeJob.on 'complete', (result) =>
      cb(result)
  @dnodeSearch: (s, cb) ->
    console.log(s)
    cb(s)
  @authenticate: (job, done) ->
    {chatId} = job.data
    user.get chatId, (err, list) ->
      if err
        done(err)
      else
        {id, created, type, username, first_name, last_name} = JSON.parse list
        pass = crypto.createHash('md5').update("#{created}").digest("hex")
        done(null,
          user:id,
          pass:pass,
          first_name:first_name,
          last_name:last_name,
          username:username,
          type:type
        )
  @getTokens: (job, done) ->
    {chatId} = job.data
    token.get chatId, (err, list) =>
      if err
        done(err)
      else
        if list
          done(null, list)
        else
          done(err)
  @create: (job, done) ->
    {chatId, chat, text} = job.data
    {id, type, username, first_name, last_name} = chat
    value =
      id: id
      created: +new Date()
      type: type
      username: username
      first_name: first_name
      last_name: last_name
    user.get id, (err, list) =>
      if err
        user.put id, JSON.stringify(value), (err) ->
          if not err
            job = queue.create('sendMessage',
              title: "Create new profile. ID: #{id}."
              chatId: chatId
              text: "#{text}Create new profile. ID: #{id}").save()
            done(null, list)
          else
            done(err)
      else
        job = queue.create('sendMessage',
          title: "Profile already exists. ID: #{id}."
          chatId: chatId
          text: "#{text}Profile already exists ID: #{id}").save()
        done()
  @saveTokens: (job, done) ->
    {access_token, expires_in, user_id, email, chatId, first} = job.data
    value =
      id: chatId
      expires_in: expires_in
      user_id: user_id
      network: first
      email: email
      access_token: access_token
    token.put chatId, JSON.stringify(value), (err) ->
      if err
        done(new Error("Error! SaveTokens. #{triple}"))
      else
        token.get chatId, (err, list) ->
          if err
            done err
          else
            queue.create('sendMessage',
              title: "Send support text. Telegram UID: #{chatId}."
              chatId: chatId
              text: "Token saved.").save()
            done()
  @session: (job, done) ->
    {chatId, text} = job.data
    user.get chatId, (err, list) ->
      if err
        done(err)
      else
        if list
          {id, created, type, username, first_name, last_name} = JSON.parse list
          pass = crypto.createHash('md5').update("#{created}").digest("hex")
          job = queue.create('sendMessage',
            title: "Generate access link. Telegram UID: #{chatId}."
            chatId: chatId
            text: text + "http://#{PANEL_HOST}:#{PANEL_PORT}/?_s=#{chatId}:#{pass}").save()
          done()
        else
          done('err')
  @browserify: (job, done) ->
    {browserCoffee, bundleJs} = job.data
    bundle = browserify
      extensions: ['.coffee.md']
    bundle.transform coffeeify,
      bare: false
      header: false
    bundle.add browserCoffee
    bundle.bundle (error, js) ->
      throw error if error?
      writeFileSync bundleJs, js
      done()
  @coffeelint: (job, done) ->
    {files} = job.data
    command = 'coffeelint ' + "#{files.join(' ')}"
    exec command, (err, stdout, stderr) ->
      console.log(command)
      console.log(stdout, stderr)
      done()
  @mediaAnalyzer: (job, done) ->
        {chatId, href, host, path} = job.data
        GetTokensJob = queue.create('getTokens',
          title: 'Get Tokens',
          chatId: chatId).save()
        GetTokensJob.on 'complete', (result) ->
          {access_token} = JSON.parse result
          if access_token
            params =
              access_token: access_token
              offset: 0
              count: 100
              extended: 0
              filter: 'all'
              v: VK_VERSION
            if 'id' in path
              params.owner_id = path[3..path.length]
            else
              params.domain = path[1..path.length]
            vkMediaScraperJob = queue.create('vkMediaScraper',
              title: "mediaScraper Telegram UID: #{chatId}.",
              chatId: chatId,
              method: 'wall.get',
              params: params,
              items: []).save()
            done()
          else
            done('Error! Can`t find access_token.')
  @mediaChecker: (job, done) ->
    {chatId, text} = job.data
    rawLinks = UnderTheRules.tokenizer.tokenize(text)
    if rawLinks.length < 1
      queue.create('sendMessage',
        title: "mediaChecker Telegram UID: #{chatId}."
        chatId: chatId
        text: 'Unknown command. List of commands: /help.').save()
    rawLinks.forEach (item) ->
      {href, host, path} = url.parse(item)
      switch host
        when 'vk.com'
          if path
            queue.create('mediaAnalyzer',
              title: "Analyze Media #{href}",
              chatId: chatId,
              href: href,
              host: host,
              path: path).save()
      done()
  @vkMediaScraper: (job, done) ->
    {chatId, method, params, items} = job.data
    requestUrl = "https://api.vk.com/method/#{method}?#{querystring.stringify(params)}"
    request requestUrl, (error, response, body) =>
      if not error and response.statusCode is 200
        body = JSON.parse(body)
        if items.length is 0
          queue.create('sendMessage',
            title: "vkMediaScraper Telegram UID: #{chatId}.",
            chatId: chatId,
            text: 'Empty Wall').save()
          done()
          return
        if (body.response.count - params.offset) > 0
          params.offset += 100
          items = items.concat(body.response.items)
          vkMediaScraperJob = queue.create('vkMediaScraper',
            title: "mediaScraper Telegram UID: #{chatId}.",
            chatId: chatId,
            method: 'wall.get',
            params: params,
            items: items).save()
        else
          vkWallStaticJob = queue.create('vkWallStatic',
            title: "vkWallStatic Telegram UID: #{chatId}.",
            chatId: chatId,
            name: (params.domain || params.user_id),
            items: items).save()
          vkWallStaticJob.on 'complete', (result) =>
            queue.create('sendDocument',
              title: "vkWallStaticJob Telegram UID: #{chatId}.",
              chatId: chatId,
              filePath: result).save()
            done()
      else
        done(error)
    done()
  @vkWallStatic: (job, done) ->
    {chatId, name, items} = job.data
    filename = "#{STATIC_DIR}/files/#{name}-wall-#{items.length}.csv"
    fs.writeFileSync filename, "id;link;from_id;owner_id;date;post_type;comments;likes;reposts\n"
    [first, ..., last] = items
    rows = ''
    for item in items
      {id,from_id,owner_id,date,post_type,comments,likes,reposts} = item
      rows += "#{id};https://vk.com/wall#{owner_id}_#{id};#{from_id};#{owner_id};#{new Date(date*1000)};#{post_type};#{comments.count};#{likes.count};#{reposts.count}\n"
      if id is last.id
        fs.appendFileSync filename, rows
        done(null, filename)
  @panel: (job, done) ->
    {chatId, text} = job.data
    if !chatId? or !text?
      return done(new Error("Error! at panelHandler. Faild to send text."))
    queue.create('session',
      title: "Create new session. Telegram UID: #{chatId}.",
      chatId: chatId,
      text: "#{text}\n\n").save()
    done()
  @sendCode: (job, done) ->
    {code, chatId, network} = job.data
    vkUrl  = 'https://oauth.vk.com/access_token?'
    vkUrl += "client_id=#{VK_CLIENT_ID}&client_secret=#{VK_CLIENT_SECRET}&"
    vkUrl += "redirect_uri=http://#{VK_REDIRECT_HOST}:#{VK_REDIRECT_PORT}/&"
    vkUrl +=  "code=#{code}"
    request vkUrl, (error, response, body) ->
      if !error and response.statusCode == 200
        {access_token, expires_in,user_id,email} = JSON.parse(body)
        queue.create('saveTokens',
          title: "Send support text. Telegram UID: #{chatId}."
          chatId: chatId,
          access_token: access_token,
          expires_in: expires_in,
          user_id: user_id,
          email: email
          network: network).save()
        done()
  @pugRender: (job, done) ->
    {templatePug, indexHtml} = job.data
    writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)
    done()
  @start: (job, done) ->
    {chatId, text, chat} = job.data
    if !chatId? or !text? or !chat?
      return done(new Error("Start Handler Error.\nUID: #{chatId}\nText: #{text}\nData: #{chat}"))
    queue.create('create',
      title: "Create new profile. Telegram UID: #{chatId}.",
      chat: chat,
      chatId: chatId,
      text: "#{text}\n\n").save()
    done()
  @static: (job, done) ->
    {STATIC_DIR ,htdocsFaviconIco, staticFaviconIco, htdocsImg, staticImg} = job.data
    mkdirsSync STATIC_DIR
    mkdirsSync "#{STATIC_DIR}/files"
    copySync htdocsImg, staticImg
    copySync htdocsFaviconIco, staticFaviconIco
    done()
  @support: (job, done) ->
    {chatId, text} = job.data
    if !chatId? or !text?
      return done(new Error("Support Handler Error.\nUID: #{chatId}\Text: #{text}"))
    queue.create('sendMessage',
      title: "Send support text. Telegram UID: #{chatId}."
      chatId: chatId
      text: text).save()
    done()
  @stylusRender: (job, done) ->
    {styleStyl, styleCss} = job.data
    handler = (err, css) ->
      if err then throw err
      writeFileSync styleCss, css
    content = readFileSync(styleStyl, {encoding:'utf8'})
    stylus.render(content, handler)
    done()

# Master

if cluster.isMaster

## Kue
  kue.app.set('title', 'Under The Rules')
  kue.app.listen KUE_PORT, ->
    console.log("Kue: http://0.0.0.0:#{KUE_PORT}.")
    kue.Job.rangeByState 'complete', 0, 100000, 'asc', (err, jobs) ->
      jobs.forEach (job) ->
        job.remove -> return

## Ecstatic is a simple static file server middleware.
  ecstatic = require('ecstatic')(STATIC_DIR)
  server   = http.createServer(ecstatic) # Create a HTTP server.


## Starting Dnode. Using dnode via shoe & Install endpoint
  server.listen PANEL_PORT, -> #  PANEL_HOST,
    console.log("Dnode: http://#{PANEL_HOST}:#{PANEL_PORT}")
  sock = shoe (stream) ->
    d = dnode # Define API object providing integration vith dnode
      sendCode: UnderTheRules.dnodeSendCode
      search: UnderTheRules.dnodeSearch
      auth: UnderTheRules.dnodeAuth
    d.pipe(stream).pipe(d)
  sock.install(server, '/dnode')

## Level. Initializing users, tokens
  # history = levelgraph(level(LEVEL_DIR + '/history'))
  ensureDirSync LEVEL_DIR # Create Level Dir folder
  log = level(LEVEL_DIR + '/log', {type:'json'})
  user = level(LEVEL_DIR + '/user', {type:'json'})
  token = level(LEVEL_DIR + '/token', {type:'json'})
  queue.process 'create', UnderTheRules.create
  queue.process 'session', UnderTheRules.session
  queue.process 'authenticate', UnderTheRules.authenticate
  queue.process 'saveTokens', UnderTheRules.saveTokens
  queue.process 'getTokens', UnderTheRules.getTokens

## Create Jobs
  staticJob = queue.create('static',
    title: "Copy images from HTDOCS_DIR to STATIC_DIR",
    STATIC_DIR:STATIC_DIR,
    htdocsFaviconIco:htdocsFaviconIco,
    staticFaviconIco:staticFaviconIco,
    htdocsImg:htdocsImg
    staticImg:staticImg).save()
  staticJob.on 'complete', () ->
    queue.create('pugRender',
      title: "Render (transform) pug template to html",
      templatePug:templatePug,
      indexHtml:indexHtml).delay(100).save()
    queue.create('stylusRender',
      title: "Render (transform) stylus template to css",
      styleStyl:styleStyl,
      styleCss:styleCss).delay(100).save()
    queue.create('browserify',
      title: "Render (transform) coffee template to js"
      browserCoffee:browserCoffee,
      bundleJs:bundleJs).delay(100).save()
    queue.create('coffeelint',
      title: "Link coffee files"
      files:[clusterCoffee]).delay(100).save() # browserCoffee

## **Clean** job list on exit add to class
  exitHandler = (options, err) =>
    if err
      console.log err.stack
    if options.exit
      process.exit()
      return
    if options.cleanup
      removeSync STATIC_DIR

## 1) *do something when app is closing* 2) *ctrl+c event* 3) *uncaught exceptions*
  process.on 'exit', exitHandler.bind(null, cleanup: true)
  process.on 'SIGINT', exitHandler.bind(null, exit: true)
  process.on 'uncaughtException', exitHandler.bind(null, exit: true)

  i = 2
  while i < numCPUs
    cluster.fork()
    i++
# Worker
else
  queue.process 'sendCode', UnderTheRules.sendCode
  queue.process 'coffeelint', UnderTheRules.coffeelint
  queue.process 'vkWallStatic', UnderTheRules.vkWallStatic
  queue.process 'vkMediaScraper', UnderTheRules.vkMediaScraper
  queue.process 'mediaAnalyzer', UnderTheRules.mediaAnalyzer
  queue.process 'mediaChecker', UnderTheRules.mediaChecker
  queue.process 'start', UnderTheRules.start
  queue.process 'panel', UnderTheRules.panel
  queue.process 'support', UnderTheRules.support
  queue.process 'static', UnderTheRules.static
  queue.process 'pugRender', UnderTheRules.pugRender
  queue.process 'stylusRender', UnderTheRules.stylusRender
  queue.process 'browserify', UnderTheRules.browserify
