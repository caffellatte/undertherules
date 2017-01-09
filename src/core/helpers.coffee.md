# helpers.coffee.md

Helpful functions & constants.

## Import NPM modules

    _          = require('lodash')
    os         = require('os')
    fs         = require('fs-extra')
    pug        = require('pug')
    dnode      = require('dnode')
    crypto     = require('crypto')
    request    = require('request')
    stylus     = require('stylus')
    cli_table  = require('cli-table')
    coffeeify  = require('coffeeify')
    browserify = require('browserify')
    Telegram   = require('telegram-node-bot')

## Getter Prototype

    Function::property = (prop, desc) ->
      Object.defineProperty @prototype, prop, desc

## Import environment parameters

    {KUE_PORT, STATIC_PATH, DNODE_PORT, LEVEL_DNODE_PORT} = process.env
    utf8 = {encoding:'utf8'}

## Extract functions from modules

    {log}              = console
    {exec}             = require 'child_process'
    {stringify, parse} = JSON
    {writeFileSync, readFileSync, removeSync, mkdirsSync, copySync} = fs
    {TelegramBaseController} = Telegram

## Texts & other string content

    helpText = '''
      /start - Create profile
      /panel - Goto dashboad
      /about - Contacts & etc
      /help - List of commands
      '''

    startText = '''
      Flexible environment for social network analysis (SNA).
      Software provides full-cycle of retrieving and subsequent
      processing data from the social networks.
      Usage: /help. More: /about. Dashboard: /panel.'''

    aboutText = '''
      Undertherules, MIT license
      Copyright (c) 2016 Mikhail G. Lutsenko
      Mail: m.g.lutsenko@gmail.com
      Telegram: @sociometrics'''

    githubText = 'Package: https://github.com/caffellatte/undertherules'

## OS utility methods array

    osUtils = ['hostname', 'loadavg', 'uptime', 'freemem',
      'totalmem', 'cpus', 'type', 'release',
      'networkInterfaces', 'arch', 'platform']

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

## Timestamp to pretty date transform
Simple coffeescript method to  convert a unix timestamp to  a date.
Function return example: '2016.03.11 12:26:51'
http://stackoverflow.com/questions/847185/

    DatePrettyString = (timestamp, sep = ' ') ->
      zeroPad = (x) ->
        return if x < 10 then '0' + x else '' + x
      date = new Date(timestamp)
      d = zeroPad(date.getDate())
      m = +zeroPad(date.getMonth()) + 1
      y = date.getFullYear()
      h = zeroPad(date.getHours())
      n = zeroPad(date.getMinutes())
      s = zeroPad(date.getSeconds())
      return "#{y}.#{m}.#{d}#{sep}#{h}:#{n}:#{s}"


## Formatter for big numbers
* 999 < num < 999999 add postfix *K*
* For num > 999999 add postfix *M*


    Formatter = (num, base = 1000) ->
      if num > 999 and num < 999999 then (num / base).toFixed(1) + 'K'
      else if num > 999999 then (num / (base * base)).toFixed(1) + 'M'
      else num

## cake hint

    Hint = (helpersCoffeeMd, hiveCoffeeMd) ->
      command = 'coffeelint ' + "#{helpersCoffeeMd} #{hiveCoffeeMd}"
      exec command, (err, stdout, stderr) ->
        log('coffeelint ', helpersCoffeeMd)
        log(stdout, stderr)

## cake env

    Env = (_env, env, _Procfile, Procfile, _db) ->
      writeFileSync _env, env
      log "write file #{_env}"
      writeFileSync _Procfile, Procfile
      log "write file #{_Procfile}"
      mkdirsSync _db
      log "make dir   #{_db}"

## cake htdocStatic

    HtdocsStatic = (_static, imgHtdocs, imgStatic, favicon, _favicon) ->
      mkdirsSync _static
      log "make folder #{_static}"
      copySync imgHtdocs, imgStatic
      log "copy folder #{imgHtdocs} -> #{imgStatic}"
      copySync favicon, _favicon
      log "copy file #{favicon} -> #{_favicon}"

# #cake pug

    Pug = (templatePug, indexHtml) ->
      writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)
      log "render file #{templatePug} -> #{indexHtml}"

## cake stylus

    HtdocsStylus = (styleStyl, styleCss) ->
      handler = (err, css) ->
        if err then throw err
        writeFileSync styleCss, css
        log "render file #{styleStyl} -> #{styleCss}"
      content = readFileSync(styleStyl, utf8)
      stylus.render(content, handler)

## cake browserify

    HtdocsBrowserify = (mainCoffeeMd, bundleJs) ->
      bundle = browserify
        extensions: ['.coffee.md']
      bundle.transform coffeeify,
        bare: false
        header: false
      bundle.add mainCoffeeMd
      bundle.bundle (error, js) ->
        throw error if error?
        writeFileSync bundleJs, js
        log "render file #{mainCoffeeMd} -> #{bundleJs}"

## cake clean

    Clean = (_env, _static, _Procfile) ->
        [
          _env
          _static
          _Procfile
          '.db'
        ].forEach (item) ->
          removeSync item
          log "removeSync #{item}"

## Class for managing Kue jobs via HTTP API

    class KueJobHelper
      constructor:(@name = 'utr') ->
        @url     = "http://0.0.0.0:#{KUE_PORT}/job"
        @headers = {'Content-Type':'application/json'}
        @method  = 'POST'
      create:(type, data) ->
        requestData = {
          url:@url
          headers:@headers
          method:@method
        }
        if not data.options?
          data.options  =
            attempts: 5
            priority: 'normal'
            delay: 0
        _options = {
          attempts:data.options.attempts
          priority:data.options.priority
          delay:data.options.delay
        }
        requestData.json = {
          type:type
          data:{
            title:"[#{type}] #{data.chat.id}> #{data.text}"
            text:data.text
            chat:data.chat.id
            _data:data
          }
          options:_options
        }
        requestHandler = (error, response, body) ->
          if error
            log(JSON.stringify(error, null, 2))
          else
            log("HTTP-API> #{body.message} Kue id: #{body.id}")
        request(requestData, requestHandler)

### Create instance of class

    KueJob = new KueJobHelper()

## Start Handler

    startHandler = (data, done) ->
      {chat, text, _data} = data
      if !chat? or !text?
        errorText = "Error! (startHandler): #{data}"
        log errorText
        return done(new Error(errorText))
      d = dnode.connect(LEVEL_DNODE_PORT)
      d.on 'remote', (remote) ->
        remote.start _data, (s) ->
          d.end()
          dataSendMessage =
            title: "startHandler: [#{text}]: #{chat})"
            chat:  {id: chat}
            text:  text + "\nYour profile id: #{s.subject}."
          KueJob.create('sendMessage', dataSendMessage)
          done()

# Class StartController

    class StartController extends TelegramBaseController
      constructor: () ->
      startHandler: ($) ->
        data    =
          text: startText
          chat: $.message.chat
        KueJob.create('start', data)
      @property 'routes',
        get: -> 'startCommand': 'startHandler'

##  Help Handler

    helpHandler = (data, done) ->
      {chat, text} = data
      if !chat? or !text?
        errorText = "Error! [kue.coffee](startHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title: "helpHandler: [#{text}]: #{chat})"
        chat:  {id: chat}
        text:  text
      KueJob.create('sendMessage', dataSendMessage)
      done()

## Class HelpController

    class HelpController extends TelegramBaseController
      constructor: () ->
      helpHandler: ($) ->
        data    =
          text: helpText
          chat: $.message.chat
        KueJob.create('help', data)
      @property 'routes',
        get: -> 'helpCommand': 'helpHandler'

## About Handler

    aboutHandler = (data, done) ->
      {chat, text} = data
      if !chat? or !text?
        errorText = "Error! [kue.coffee](aboutHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title: "aboutHandler: [#{text}]: #{chat})"
        chat:  {id: chat}
        text:  text
      KueJob.create('sendMessage', dataSendMessage)
      done()

## Class AboutController

    class AboutController extends TelegramBaseController
      constructor: () ->
      aboutHandler: ($) ->
        type    = 'about'
        data    =
          text: aboutText
          chat: $.message.chat
        KueJob.create(type, data)
      @property 'routes',
        get: -> 'aboutCommand': 'aboutHandler'

## Panel Handler

    panelHandler = (data, done) ->
      {chat, text} = data
      if !chat? or !text?
        errorText = "Error! at panelHandler. Faild to send text."
        log errorText
        return done(new Error(errorText))
      d = dnode.connect(LEVEL_DNODE_PORT)
      d.on 'remote', (remote) ->
        remote.panel chat, (s) ->
          {subject, object} = s
          {user, pass} =  DnodeCrypto subject, object
          d.end()
          dataSendMessage =
            title: "panelHandler: [#{text}]: #{chat})"
            chat:  {id: chat}
            text:  text + "\n http://0.0.0.0:#{DNODE_PORT}/?_s=#{user}:#{pass}." # Generate link
          KueJob.create('sendMessage', dataSendMessage)
          done()

## Class ConfigController

    class PanelController extends TelegramBaseController
      constructor: () ->
      panelHandler: ($) ->
        data    =
          text: 'Link allows you to access the dashboad.\nIt will expire after every 24 hours.'
          chat: $.message.chat
        KueJob.create('panel', data)
      @property 'routes',
        get: -> 'panelCommand': 'panelHandler'

## Class OtherwiseController

    class OtherwiseController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      handle: ($) ->
        $.sendMessage 'Unknown commands. Try /help.'
        return

## Telegram + Web Auth

    DnodeCrypto = (subject, object) ->
      nub = +new Date() // (1000 * 60 * 60 * 24)
      _a = subject % nub + nub * subject
      _b = object % subject + object % nub + subject % nub + (object - subject) // nub
      _login = subject * nub
      _passwd = crypto.createHash('md5').update("#{_b}#{subject}#{_a}#{object}").digest("hex")
      return {user: _login, pass: _passwd}

## Exports functions & constants

    module.exports.DnodeCrypto         = DnodeCrypto
    module.exports.DatePrettyString    = DatePrettyString
    module.exports.DisplaySysInfo      = DisplaySysInfo
    module.exports.SysInfo             = SysInfo
    module.exports.Formatter           = Formatter
    module.exports.startText           = startText
    module.exports.aboutText           = aboutText
    module.exports.helpText            = helpText
    module.exports.Hint                = Hint
    module.exports.Env                 = Env
    module.exports.Pug                 = Pug
    module.exports.HtdocsStylus        = HtdocsStylus
    module.exports.HtdocsBrowserify    = HtdocsBrowserify
    module.exports.HtdocsStatic        = HtdocsStatic
    module.exports.Clean               = Clean
    module.exports.StartController     = StartController
    module.exports.startHandler        = startHandler
    module.exports.helpHandler         = helpHandler
    module.exports.HelpController      = HelpController
    module.exports.aboutHandler        = aboutHandler
    module.exports.AboutController     = AboutController
    module.exports.panelHandler        = panelHandler
    module.exports.PanelController     = PanelController
    module.exports.OtherwiseController = OtherwiseController

## More: [undertherules](https://github.com/caffellatte/undertherules)
