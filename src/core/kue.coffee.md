# kue.coffee.md

* Kue job (task) processing that include the most part of bakcground work.
* Dnode uses the streaming interface provided by shoe,which is just
a thin wrapper on top of sockjs that provides websockets with fallbacks.

## Import NPM modules

    kue        = require('kue')
    dnode      = require('dnode')
    cluster    = require('cluster')
    helpers    = require('./helpers.coffee.md')

## Extract functions & constans from modules

    {log}                                   = console
    {cpus}                                  = helpers.SysInfo()
    {parse}                                 = require 'url'
    {DatePrettyString, Formatter}           = helpers
    {KUE_PORT}                              = process.env

## track

    track = (data, done) ->
      log data
      done()

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

## Parallel Processing With Cluster

When cluster **.isMaster** the file is being executed in context of the master
process, in which case you may perform tasks that you only want once, such
as starting the web app bundled with Kue.

    if cluster.isMaster

## Start Kue

      kue.app.set('title', 'Under The Rules')
      # kue.Job.rangeByState 'complete', 0, 1000, 'asc', (err, jobs) ->
        # jobs.forEach (job) ->
          # job.remove ->
            # console.log 'removed ', job.id
      kue.app.listen KUE_PORT, ->
        log("Priority queue (cluster) started.\nWeb: http://0.0.0.0:#{KUE_PORT}.")

## Fork workers

        i = 1
        while i < cpus.length
          cluster.fork()
          i += 1

## The logic in the else block is executed **per worker**.

    else
      {id} = cluster.worker
      log("Worker [#{id}] started.")
      queue.process 'track',       (job, done) -> track job.data, done
