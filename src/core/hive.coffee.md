# hive.coffee.md

* Kue job (task) processing that include the most part of bakcground work.
* Dnode uses the streaming interface provided by shoe,which is just
a thin wrapper on top of sockjs that provides websockets with fallbacks.

## Import NPM modules

    kue        = require('kue')
    http       = require('http')
    path       = require('path')
    shoe       = require('shoe')
    dnode      = require('dnode')
    request    = require('request')
    cluster    = require('cluster')
    helpers    = require('./helpers.coffee.md')
    Telegram   = require('telegram-node-bot')

## Extract functions & constans from modules

    {log}                                   = console
    {cpus}                                  = helpers.SysInfo()
    {parse}                                 = require 'url'
    {TextCommand}                           = Telegram
    {DatePrettyString, Formatter}           = helpers
    {findHandler, helpHandler, listHandler} = helpers
    {startHandler, aboutHandler}            = helpers
    {configHandler, trackHandler}           = helpers
    {StartController, HelpController}       = helpers
    {TrackController, FindController}       = helpers
    {ListController, AboutController}       = helpers
    {ConfigController, OtherwiseController} = helpers
    {sendMessage}                           = helpers
    {DNODE_PORT, KUE_PORT, STATIC_PATH}     = process.env
    {TELEGRAM_TOKEN}                        = process.env

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

## Create Telegram instance interface

    tg = new Telegram.Telegram TELEGRAM_TOKEN, {workers: 1}


## Define API object providing integration vith dnode

    API = {
      dateTime: (s, cb) ->
        currentDateTime = DatePrettyString(s)
        cb(currentDateTime)
      search: (s, cb) ->
        log(s)
        cb(s)
    }

## Telegram Bot Router

    tg.router
      .when new TextCommand('start',  'startCommand'),   new StartController(queue)
      .when new TextCommand('help',   'helpCommand'),    new HelpController(queue)
      .when new TextCommand('track',  'trackCommand'),   new TrackController(queue)
      .when new TextCommand('find',   'findCommand'),    new FindController(queue)
      .when new TextCommand('list',   'listCommand'),    new ListController(queue)
      .when new TextCommand('about',  'aboutCommand'),   new AboutController(queue)
      .when new TextCommand('config', 'configCommand'),  new ConfigController(queue)
      .otherwise new OtherwiseController()

## Parallel Processing With Cluster

When cluster **.isMaster** the file is being executed in context of the master
process, in which case you may perform tasks that you only want once, such
as starting the web app bundled with Kue.

    if cluster.isMaster

## Start Kue

      kue.app.set('title', 'Under The Rules')
      kue.app.listen KUE_PORT, ->
        log("Priority queue (cluster) started. Listen port: #{KUE_PORT}.")

## A simple static file server middleware. Using it with a raw http server

      ecstatic = require('ecstatic')(STATIC_PATH)

## Create HTTP static server

      server = http.createServer(ecstatic)

## Start Dnode

      server.listen DNODE_PORT, ->
        log("""
        RPC module (dnode) successful started. Listen port: #{DNODE_PORT}.
        Web: http://0.0.0.0:#{DNODE_PORT}
        """)

## Use dnode via shoe & Install endpoint

      sock = shoe((stream) ->
        d = dnode(API)
        d.pipe(stream).pipe(d)
      )
      sock.install(server, '/dnode')

## Fork workers

      i = 1
      while i < cpus.length
        cluster.fork()
        i += 1

## The logic in the else block is executed **per worker**.

    else
      {id} = cluster.worker
      log("Worker [#{id}] started.")
      queue.process 'sendMessage', (job, done) -> sendMessage   job.data, tg, done
      queue.process 'start',       (job, done) -> startHandler  job.data, queue, done
      queue.process 'help',        (job, done) -> helpHandler   job.data, queue, done
      queue.process 'track',       (job, done) -> trackHandler  job.data, queue, done
      queue.process 'find',        (job, done) -> findHandler   job.data, queue, done
      queue.process 'list',        (job, done) -> listHandler   job.data, queue, done
      queue.process 'about',       (job, done) -> aboutHandler  job.data, queue, done
      queue.process 'config',      (job, done) -> configHandler job.data, queue, done
