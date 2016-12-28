kue.coffee
==========

* Kue job (task) processing that include the most part of bakcground work.
* Dnode uses the streaming interface provided by shoe,which is just
a thin wrapper on top of sockjs that provides websockets with fallbacks.

## Import NPM modules

    kue        = require('kue')
    http       = require('http')
    shoe       = require('shoe')
    dnode      = require('dnode')
    cluster    = require('cluster')
    helpers    = require('./helpers.coffee.md')

## Extract functions & constans from modules

    {log}                               = console
    {cpus}                              = helpers.SysInfo()
    {DatePrettyString}                  = helpers
    {DNODE_PORT, KUE_PORT, STATIC_PATH} = process.env

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

## Define API object providing integration vith dnode

    API = {
      dateTime: (s, cb) ->
        currentDateTime = DatePrettyString(s)
        cb(currentDateTime)
    }

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

      i = 0
      while i < cpus.length
        cluster.fork()
        i += 1

## The logic in the else block is executed **per worker**.

    else
      {id} = cluster.worker
      log("Worker [#{id}] started.")
