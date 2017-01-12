# kue.coffee.md

* Kue job (task) processing that include the most part of bakcground work.
* Dnode uses the streaming interface provided by shoe,which is just
a thin wrapper on top of sockjs that provides websockets with fallbacks.

## Import NPM modules

    _          = require('lodash')
    fs         = require('fs-extra')
    os         = require('os')
    kue        = require('kue')
    pug        = require('pug')
    dnode      = require('dnode')
    crypto     = require('crypto')
    stylus     = require('stylus')
    cluster    = require('cluster')
    cli_table  = require('cli-table')


## Extract information about OS
The os module provides a number of operating system-related utility methods.

    SysInfo = ->
      utils = {}
      ({"#{utl}":"#{stringify(os[utl]())}"} for utl in osUtils).forEach( (item) ->
        for key, value of item
          utils[key] = parse(value)
      )
      return utils

### **Display pretty tables with about os**
Extract vars from data object.

    DisplaySysInfo = (data) ->
      {hostname, loadavg, uptime, freemem, totalmem}           = data
      {cpus, type, release, networkInterfaces, arch, platform} = data

### **Information about hostname, uptime, type, release, arch, platform**

      mainTable = new cli_table()
      mainTableArray = [
        {'Hostname':hostname}
        {'Uptime':"#{uptime // 60} min."}
        {'Architecture':arch}
        {'Platform (type)':"#{platform} (#{type})"}
        {'Release':release}
      ]
      mainTable.push(mainTableArray...)


### **CPUs information**

      numberOfCPUs = cpus.length
      cpusTable = new cli_table(
        {head:['', 'Model', 'Speed', 'User', 'Nice', 'Sys', 'IDLE', 'IRQ']}
      )
      for i in [0..numberOfCPUs - 1]
        {model, speed, times:{user, nice, sys, idle, irq}} = cpus[i]
        cpusTable.push({"CPU ##{i+1}":[model, speed, user, nice, sys, idle, irq]})


### **Memory Usage**

      memTable = new cli_table({head:['', 'Free', 'Total', '% of Free']})
      prst = (freemem / totalmem * 100).toFixed(2)
      _freemem = Formatter(freemem, 1024)
      _totalmem = Formatter(totalmem, 1024)
      memTable.push({'RAM':[_freemem , _totalmem, prst + '%']})


### **Load Average**

      loadavgTable = new cli_table({head:['', '1 min.', '5 min.', '15 min.']})
      _loadavgOne = loadavg[0].toFixed(3)
      _loadavgOFive = loadavg[1].toFixed(3)
      _loadavgOneFive = loadavg[2].toFixed(3)
      _LoadAverageArr = [_loadavgOne, _loadavgOFive, _loadavgOneFive]
      loadavgTable.push({'Load Average':_LoadAverageArr})


### **Display tables**

      log(mainTable.toString())
      log(cpusTable.toString())
      log( memTable.toString())
      log(loadavgTable.toString())

## Extract functions & constans from modules


    {log}              = console
    # {parse}            = require 'url'
    {stringify, parse} = JSON
    {exec}             = require 'child_process'
    {writeFileSync, readFileSync, removeSync, mkdirsSync, copySync} = fs
##

    {cpus}                                  = helpers.SysInfo()

    {KUE_PORT}                              = process.env
    {KUE_PORT, STATIC_PATH, DNODE_PORT, LEVEL_DNODE_PORT} = process.env
    utf8 = {encoding:'utf8'}

## cake hint

    Hint = (coffeeFiles) ->
      command = 'coffeelint ' + "#{coffeeFiles.join(' ')}"
      exec command, (err, stdout, stderr) ->
        log('coffeelint ', helpersCoffeeMd)
        log(stdout, stderr)



## cake clean

    Clean = (_env, _static, _Procfile) ->
        [
          _static
          '.db'
        ].forEach (item) ->
          removeSync item
          log "removeSync #{item}"


    task 'hint', 'JavaScript Source Code Analyzer via coffee-jshint', ->
      Hint(coffeeFiles)

    task 'os', 'Display information about Operation System.', ->
      DisplaySysInfo(SysInfo())

    task 'env', 'Add .env, Procfile (foreman) & database folders.', ->
      Env(_env, env, _Procfile, Procfile, _db)

    task 'clean', 'Remove `.env` file, `static` folder & etc.', ->
      Clean(_env, _static, _Procfile)


## File & Folders Structure

    Folders =
      _db:  "#{__dirname}/.db/"

    Files =

      imgHtdocs         = "#{__dirname}/src/htdocs/img"
      favicon           = "#{__dirname}/src/htdocs/img/favicon.ico"
      templatePug       = "#{__dirname}/src/htdocs/template.pug"
      styleStyl         = "#{__dirname}/src/htdocs/style.styl"
      mainCoffeeMd      = "#{__dirname}/src/htdocs/main.coffee.md"
      _static           = "#{__dirname}/static"
      imgStatic         = "#{__dirname}/static/img"
      _favicon          = "#{__dirname}/static/favicon.ico"
      indexHtml         = "#{__dirname}/static/index.html"
      styleCss          = "#{__dirname}/static/style.css"
      bundleJs          = "#{__dirname}/static/bundle.js"
      helpersCoffeeMd   = "#{__dirname}/src/core/helpers.coffee.md"
      kueCoffeeMd       = "#{__dirname}/src/core/kue.coffee.md"
      levelCoffeeMd     = "#{__dirname}/src/core/level.coffee.md"
      panelCoffeeMd     = "#{__dirname}/src/core/panel.coffee.md"
      networksCoffeeMd  = "#{__dirname}/src/core/networks.coffee.md"
      telegramCoffeeMd  = "#{__dirname}/src/core/telegram.coffee.md"

    coffeeFiles = [
      mainCoffeeMd
      kueCoffeeMd
      levelCoffeeMd
      panelCoffeeMd
      networksCoffeeMd
      telegramCoffeeMd
    ]

## OS utility methods array

    osUtils = ['hostname', 'loadavg', 'uptime', 'freemem',
      'totalmem', 'cpus', 'type', 'release',
      'networkInterfaces', 'arch', 'platform']

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
      kue.Job.rangeByState 'complete', 0, 1000, 'asc', (err, jobs) ->
        jobs.forEach (job) ->
          job.remove ->
            console.log 'removed ', job.id
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
