kue.coffee
==========

* Kue job (task) processing that include the most part of bakcground work.
* Dnode uses the streaming interface provided by shoe,which is just
a thin wrapper on top of sockjs that provides websockets with fallbacks.

## Import NPM modules

    kue        = require 'kue'
    http       = require 'http'
    shoe       = require 'shoe'
    dnode      = require 'dnode'
    cluster    = require 'cluster'
    helpers    = require './helpers.coffee.md'

## Extract functions & constans from modules

    { log }                               = console
    { cpus }                              = helpers.SysInfo()
    { DNODE_PORT, KUE_PORT, STATIC_PATH } = process.env

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

## Define API object providing integration vith dnode

    echo = (data, done) ->
      log data
      done()

    API =
      echo: (s, cb) ->
        job = queue.create('echo',
          title: 'echo'
          data: s).save((err) ->
          if !err
            console.log job.id
          return
        )
        log s
        cb s
        return

## Parallel Processing With Cluster

When cluster **.isMaster** the file is being executed in context of the master
process, in which case you may perform tasks that you only want once, such
as starting the web app bundled with Kue.

    if cluster.isMaster

## Start Kue

      kue.app.set 'title', 'Under The Rules'
      kue.app.listen KUE_PORT, ->
        log "Priority job queue (cluster) successful started. Listen port: #{KUE_PORT}."

## A simple static file server middleware. Using it with a raw http server

      ecstatic = require('ecstatic')(STATIC_PATH)

## Create HTTP static server

      server = http.createServer(ecstatic)

## Start Dnode

      server.listen DNODE_PORT, ->
        log """
        RPC module (dnode) successful started. Listen port: #{DNODE_PORT}.
        Web: http://0.0.0.0:#{DNODE_PORT}
        """

## Use dnode via shoe & Install endpoint

      sock = shoe((stream) ->
        d = dnode API
        medium = d.pipe(stream)
        end = medium.pipe(d)
        log end
      )
      sock.install server, '/dnode'

## Fork workers

      i = 0
      while i < cpus.length
        cluster.fork()
        i++

## The logic in the else block is executed **per worker**.

    else
      {id} = cluster.worker
      log "Current worker [#{id}]"
      queue.process 'echo', (job, done) ->
        echo job.data, done
