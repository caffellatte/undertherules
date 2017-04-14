# cluster.coffee

# Modules
_             = require('lodash')
fs            = require('fs-extra')
os            = require('os')
kue           = require('kue')
pug           = require('pug')
url           = require('url')
http          = require('http')
shoe          = require('shoe')
dnode         = require('dnode')
level         = require('levelup')
crypto        = require('crypto')
stylus        = require('stylus')
natural       = require('natural')
cluster       = require('cluster')
request       = require('request')
coffeeify     = require('coffeeify')
browserify    = require('browserify')
cookiefile    = require('cookiefile')
querystring   = require('querystring')
child_process = require('child_process')

# Texts
helpText = '''
  Flexible environment for social network analysis (SNA).
  Software provides full-cycle of retrieving and subsequent
  processing data from the social networks.
  Usage: /help. Contacts: /about.

  Under The Rules, MIT license
  Copyright (c) 2016 Mikhail G. Lutsenko
  Github: https://github.com/caffellatte
  Npm: https://www.npmjs.com/~caffellatte
  Telegram: https://telegram.me/caffellatte'''

# Functions
{exec} = child_process
{CookieMap} = cookiefile
{writeFileSync, readFileSync} = fs
{removeSync, mkdirsSync, copySync, ensureDirSync} = fs

# Request Cookies
cookieFile = new CookieMap(IG_COOKIE)
CookieFile = cookieFile.toRequestHeader()

# Environment
numCPUs = require('os').cpus().length
{KUE_PORT, KUE_HOST, PANEL_PORT, PANEL_HOST, IG_COOKIE} = process.env
{CORE_DIR, LEVEL_DIR, STATIC_DIR, HTDOCS_DIR, VK_SCOPE} = process.env
{VK_CLIENT_ID, VK_CLIENT_SECRET, VK_DISPLAY, VK_VERSION} = process.env
VK_REDIRECT_HOST = PANEL_HOST
VK_REDIRECT_PORT = PANEL_PORT

# Files
browserCoffee     = "#{HTDOCS_DIR}/browser.coffee"
clusterCoffee     = "#{CORE_DIR}/cluster.coffee"
staticJs          = "#{STATIC_DIR}/js"
staticImg         = "#{STATIC_DIR}/img"
staticFaviconIco  = "#{STATIC_DIR}/favicon.ico"
indexHtml         = "#{STATIC_DIR}/index.html"
styleCss          = "#{STATIC_DIR}/style.css"
bundleJs          = "#{STATIC_DIR}/bundle.js"
htdocsJs          = "#{HTDOCS_DIR}/js"
htdocsImg         = "#{HTDOCS_DIR}/img"
htdocsFaviconIco  = "#{HTDOCS_DIR}/img/favicon.ico"
templatePug       = "#{HTDOCS_DIR}/template.pug"
styleStyl         = "#{HTDOCS_DIR}/style.styl"

# Queue
queue = kue.createQueue()

# Cluster
class Cluster

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

  @dnodeSingIn:(graphId, cb) ->
    if typeof cb isnt 'function'
      return
    selectProfileJob = queue.create('selectProfile', {
      title:"Select Existed Profile. graphId: #{graphId}.",
      graphId:graphId
    }).save()
    selectProfileJob.on('complete', (result) ->
      if result
        cb(null, result)
      else
        cb('ACCESS DENIED')
    )

  @dnodeUpdate:(graphId, cb) ->
    if graphId
      count = 0
      Log = level(LEVEL_DIR + "/#{graphId}-log", {type:'json'})
      Log.createReadStream()
        .on('data', (data) ->
          count += 1
          cb(data.value)
        )
        .on('error', (err) ->
          cb('[LOG] Oh my!' + err)
        )
        .on('close', ->
          if count > 1 then ifOne = 's' else ifOne = ''
          cb("#{count} link#{ifOne}.")
        )
        .on('end', ->
          Log.close()
        )

  @createProfile:(job, done) ->
    {guid} = job.data
    if not guid?
      errorText = """Error! Can't create new profile.
        Timestamp: #{timestamp}, GUID: #{guid}"""
      return done(new Error(errorText))
    graphId = crypto.createHash('md5').update("#{guid}}").digest('hex')
    value = {
      graphId:graphId
      guid:guid
      timestamp:+new Date()
    }
    graph.put(graphId, JSON.stringify(value), (err) ->
      if not err
        done(null, value)
      else
        done(new Error(err))
    )

  @selectProfile:(job, done) ->
    {graphId} = job.data
    graph.get(graphId, (err, list) ->
      if err
        done(new Error(err))
      else
        if list
          done(null, JSON.parse(list))
        else
          done(new Error("Error! Type of list is '#{typeof list}'."))
    )

  @inputMessage:(graphId, msg, cb) ->
    Log = level(LEVEL_DIR + "/#{graphId}-log", {type:'json'})
    Log.put("#{graphId}-#{new Date() // 1000}", msg, (err) ->
      if err then console.log('Ooops!', err)
      Log.close()
    )
    switch msg
      when '/help' then cb(helpText)
      else
        mediaCheckerJob = queue.create('mediaChecker', {
          title:"Media Checker. GraphID: #{graphId}."
          graphId:graphId
          text:msg
        }).save()
        mediaCheckerJob.on('complete', (result) ->
          for item in result
            request("#{item}/?__a=1", (error, response, body) ->
              if not error and response.statusCode is 200
                data = JSON.parse(body)
                {id, follows_viewer, is_private} = data.user
                Users = level(LEVEL_DIR + "/#{graphId}-ig-users", {
                  type:'json'
                })
                Users.put(id, data.user, {valueEncoding:'json'}, (err) ->
                  if err then console.log('Ooops!', err)
                  Users.close()
                )
                if not (is_private is true and follows_viewer is false)
                  queue.create('igConnections', {       # Followers
                    title:'Get Instagram Followers',
                    query_id:'17851374694183129',
                    after:null,
                    first:20,
                    id:id,
                    graphId:graphId
                  }).delay(500).save()
                  queue.create('igConnections', {       # Following
                    title:'Get Instagram Followers',
                    query_id:'17874545323001329',
                    after:null,
                    first:20,
                    id:id,
                    graphId:graphId
                  }).delay(1000).save()
            )
            cb(item)
        )

  @mediaChecker:(job, done) ->
    {graphId, text} = job.data
    rawArray = Cluster.tokenizer.tokenize(text)
    rawlinks = (url.parse(link) for link in rawArray)
    links    = (link.href for link in rawlinks when link.hostname?)
    done(null, links)

  @igConnections:(job, done) ->
    {graphId, id, query_id, first, after} = job.data
    params = {query_id:query_id, after:after, first:first, id:id}
    igUrl = 'https://www.instagram.com/graphql/query/'
    igUrl += "?#{querystring.stringify(params)}"
    opts = {
      url:igUrl,
      headers:{'User-Agent':'Mozilla/5.0', 'Cookie':CookieFile}
    }
    console.log(igUrl)
    requestHandler = (error, response, json) ->
      if not error and response.statusCode is 200
        console.log(json)
        queue.create('igSave', {
          title:"Save Instagram: #{query_id}.",
          jsonData:json,
          query_id:query_id,
          id:id,
          graphId:graphId
        }).delay(500).save()
    request(opts, requestHandler)
    done()

  @igSave:(job, done) ->
    {graphId, id, jsonData, query_id} = job.data
    {edge_follow, edge_followed_by} = JSON.parse(jsonData).data.user
    {page_info, edges} = edge_follow or edge_followed_by
    {has_next_page, end_cursor} = page_info
    flag = edge_followed_by?
    if flag
      query_id = '17851374694183129'
    else
      query_id = '17874545323001329'
    queue.create('igSaveArray', {
      title:"Save Array Instagram: GraphID: #{id}.",
      flag:flag,
      edges:edges,
      query_id:query_id,
      after:end_cursor,
      first:20,
      id:id,
      graphId:graphId
    }).delay(500).save()
    if has_next_page
      queue.create('igConnections', {
        title:"Get Instagram: #{query_id}.",
        query_id:query_id,
        after:end_cursor,
        first:20,
        id:id,
        graphId:graphId
      }).delay(500).save()
    else
      queue.create('igSaveJson', {
        title:"Get Instagram: #{query_id}.",
        graphId:graphId
      }).delay(500).save()
    done()

  @igSaveArray:(job, done) ->
    {graphId, flag, edges, id} = job.data
    if flag then target = id else source = id
    nodesArray = ({
      type:'put',
      key:"#{e.node.id}",
      value:e.node,
      valueEncoding:'json'
    } for e in edges)
    edgesArray = ({
      type:'put',
      key:"#{source or e.node.id}-#{target or e.node.id}",
      value:{
        id:"#{source or e.node.id}-#{target or e.node.id}",
        source:source or e.node.id,
        target:target or e.node.id
      },
      valueEncoding:'json'
    } for e in edges)
    queue.create('igSaveBatch', {
      title:"Save Batch Instagram. GraphID: #{id}.",
      edgesArray:edgesArray,
      nodesArray:nodesArray,
      id:id,
      graphId:graphId
    }).delay(500).save()
    done()

  @igSaveBatch:(job, done) ->
    {nodesArray, edgesArray, graphId} = job.data
    Edges = level(LEVEL_DIR + "/#{graphId}-ig-edges", {type:'json'})
    Nodes = level(LEVEL_DIR + "/#{graphId}-ig-nodes", {type:'json'})
    Nodes.batch(nodesArray, (err) ->
      if err then console.log('Ooops!', err)
      console.log('Nodes added! GraphID:', graphId)
      Nodes.close()
    )
    Edges.batch(edgesArray, (err) ->
      if err then console.log('Ooops!', err)
      console.log('Edges added! GraphID:', graphId)
      Edges.close()
    )
    done()

  @igSaveJson:(job, done) ->
    {graphId} = job.data
    console.log('Save Json Instagram. GraphID:', graphId)
    # igUser.createReadStream()
    #   .on('data', (data) ->
    #     cb(data.value)
    #   )
    #   .on('error', (err) ->
    #     cb('[USER] Oh my!', err)
    #   )
    #   .on('close', ->
    #     cb('[USER] Stream closed')
    #   )
    #   .on('end', ->
    #     cb('[USER] Stream ended')
    #   )
    done()

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
    copySync(htdocsJs, staticJs)
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
      dnodeUpdate:Cluster.dnodeUpdate
      dnodeSingUp:Cluster.dnodeSingUp
      dnodeSingIn:Cluster.dnodeSingIn
      inputMessage:Cluster.inputMessage
    })
    d.pipe(stream).pipe(d)
  )
  sock.install(server, '/dnode')

  ensureDirSync(LEVEL_DIR)
  graph = level(LEVEL_DIR + '/graph', {type:'json'})

  queue.process('createProfile', Cluster.createProfile)
  queue.process('selectProfile', Cluster.selectProfile)
  queue.process('igSaveBatch', Cluster.igSaveBatch)
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
      title:'Link coffee files',
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

  queue.process('static', Cluster.static)
  queue.process('pugRender', Cluster.pugRender)
  queue.process('stylusRender', Cluster.stylusRender)
  queue.process('browserify', Cluster.browserify)
  queue.process('mediaChecker', Cluster.mediaChecker)
  queue.process('igSave', Cluster.igSave)
  queue.process('igSaveJson', Cluster.igSaveJson)
  queue.process('igSaveArray', Cluster.igSaveArray)
  queue.process('igConnections', Cluster.igConnections)
  queue.process('coffeelint', Cluster.coffeelint)
