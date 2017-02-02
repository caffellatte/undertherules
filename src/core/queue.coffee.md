# kue.coffee.md

Kue job (task) processing that include the most part of bakcground work.

## Import NPM modules

    _          = require 'lodash'
    fs         = require 'fs-extra'
    os         = require 'os'
    kue        = require 'kue'
    dnode      = require 'dnode'
    crypto     = require 'crypto'
    cluster    = require 'cluster'

## Extract functions & constans from modules

    {log}              = console
    {exec}             = require 'child_process'
    {stringify, parse} = JSON
    {removeSync, mkdirsSync, copySync} = fs

## Environment virables


    {KUE_PORT}   = process.env
    {CORE_DIR}   = process.env
    {LEVEL_DIR}  =  process.env
    {STATIC_DIR} = process.env
    {HTDOCS_DIR} = process.env
    numCPUs      = require('os').cpus().length

## File & Folders Structure

    dashCoffeeMd      = "#{HTDOCS_DIR}/dash.coffee.md"
    kueCoffeeMd       = "#{CORE_DIR}/kue.coffee.md"
    levelCoffeeMd     = "#{CORE_DIR}/level.coffee.md"
    panelCoffeeMd     = "#{CORE_DIR}/panel.coffee.md"
    networksCoffeeMd  = "#{CORE_DIR}/networks.coffee.md"
    telegramCoffeeMd  = "#{CORE_DIR}/telegram.coffee.md"
    coffeeFiles       = [
      dashCoffeeMd,
      kueCoffeeMd,
      levelCoffeeMd,
      panelCoffeeMd,
      networksCoffeeMd,
      telegramCoffeeMd
    ]

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

### Queue **coffeelint** handler

    queue.process 'coffeelint', (job, done) ->
      {files} = job.data
      command = 'coffeelint ' + "#{files.join(' ')}"
      exec command, (err, stdout, stderr) ->
        log(command)
        log(stdout, stderr)
        done()

## Parallel Processing With Cluster

When cluster **.isMaster** the file is being executed in context of the master
process, in which case you may perform tasks that you only want once, such
as starting the web app bundled with Kue.

    if cluster.isMaster

## Start Kue

      kue.app.set('title', 'Under The Rules')

      kue.app.listen KUE_PORT, ->
        log("Priority queue (cluster) started.\nWeb: http://0.0.0.0:#{KUE_PORT}.")

## **Clean** job list on exit

        exitHandler = (options, err) =>
          if err
            log err.stack
          if options.exit
            process.exit()
            return
          if options.cleanup
            log 'cleanup'
            kue.Job.rangeByState 'complete', 0, 1000, 'asc', (err, jobs) ->
              jobs.forEach (job) ->
                job.remove ->
                  console.log 'removed ', job.id

### **do something when app is closing**

        process.on 'exit', exitHandler.bind(null, cleanup: true)

### **catches ctrl+c event**

        process.on 'SIGINT', exitHandler.bind(null, exit: true)

### **catches uncaught exceptions**

        process.on 'uncaughtException', exitHandler.bind(null, exit: true)

### Create **coffeelint** Job

        # coffeelintJob = queue.create('coffeelint',
        #   title: "JavaScript Source Code Analyzer via coffee-jshint."
        #   files: coffeeFiles).save()

## Fork workers

        i = 1
        while i < numCPUs
          cluster.fork()
          i += 1

## The logic in the else block is executed **per worker**.

    else
      {id} = cluster.worker
      log("Worker [#{id}] started.")
