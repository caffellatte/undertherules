helpers.coffee
==============

Helpful functions & constants.


## Import NPM modules

    _          = require('lodash')
    os         = require('os')
    fs         = require('fs-extra')
    pug        = require('pug')
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

    {KUE_PORT, STATIC_PATH} = process.env
    utf8 = {encoding:'utf8'}

## Extract functions from modules

    {log}              = console
    {exec}             = require 'child_process'
    {stringify, parse} = JSON
    {writeFileSync, readFileSync, removeSync, mkdirsSync, copySync} = fs
    {TelegramBaseController} = Telegram

## Texts & other string content

    helpText = '''
      /start - Create profile.
      /help - Usage tips.
      /track - Track media.
      /find - Explore networks.
      /list - Analyze data.
      /about - cooperate together.
      /config - Customize setting.'''

    startText = '''
      Software provides nimble web-data operations.
      Current state: Demo. Usage: /help. More: /about.'''

    aboutText = '''
      Undertherules, MIT license
      Copyright (c) 2016 Mikhail G. Lutsenko
      Package: https://github.com/caffellatte/undertherules
      Mail: m.g.lutsenko@gmail.com
      Telegram: @sociometrics'''


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


## Class for managing Kue jobs via HTTP API

    class KueJobHelper
      constructor:(@name = 'utr') ->
        @url     = "http://localhost:#{KUE_PORT}/job"
        @headers = {'Content-Type':'application/json'}
        @method  = 'POST'
      create:(type, data, options) ->
        requestData = {
          url:@url
          headers:@headers
          method:@method
        }
        _options = {
          attempts:options.attempts
          priority:options.priority
          delay:options.delay
        }
        requestData.json = {
          type:type
          data:{
            title:"StartHandler. [#{data.chat.id}]: #{data.text}"
            text:data.text
            chat:data.chat
          }
          options:_options
        }
        requestHandler = (error, response, body) ->
          if error
            log(JSON.stringify(error, null, 2))
          else
            log('[helpers.coffee] OK, body.message Kue id: ' + body.id)
        request(requestData, requestHandler)

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

    Env = (_env, env, _Procfile, Procfile, _dbVk, _dbTg) ->
      writeFileSync _env, env
      log "write file #{_env}"
      writeFileSync _Procfile, Procfile
      log "write file #{_Procfile}"
      mkdirsSync
      log "make dir   #{_dbVk}"
      mkdirsSync _dbTg
      log "make dir   #{_dbTg}"

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

### *Telegram Send  Message*

    sendMessage = (data, tg, done) ->
      {chatId, text} = data
      if !chatId? or !text?
        log "Error! [sendMessage] Faild to send messsage: #{text} to #{chatId}."
        return done(new Error("Error! [sendMessage] Faild to send messsage."))
      tg.api.sendMessage chatId, text
      done()
      return

## Start Handler

    startHandler = (data, queue, done) ->
      {chat, text} = data
      if !chat?.id? or !text?
        errorText = "Error! [kue.coffee](startHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title:   "Send Message: '#{text}' to (#{chat.id})"
        chatId:  chat.id
        text:    text
      jobSendMessage  = queue.create('sendMessage', dataSendMessage).save((err) ->
        if !err
          log "[kue.coffee] {startHandler} (OK) Kue job id: #{jobSendMessage.id}"
        return
      )
      done()
      return

##  Help Handler

    helpHandler = (data, queue, done) ->
      {chat, text} = data
      if !chat?.id? or !text?
        errorText = "Error! [kue.coffee](startHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title:   "Send Message: '#{text}' to (#{chat.id})."
        type:    'sendMessage'
        chatId:   chat.id
        text:    text
      job = queue.create('sendMessage', dataSendMessage).save((err) ->
        if !err
          log "[kue.coffee] {helpHandler} (OK) Kue job id: #{job.id}"
        return
      )
      done()
      return

##  Track Handler

    trackHandler = (data, queue, done) ->
      {chat, text} = data
      if !chat?.id? or !text?
        errorText = "Error! [kue.coffee](trackHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title:   "Send Message: '#{text}' to (#{chat.id})."
        type:    'sendMessage'
        chatId:  chat.id
        text:    text
      job = queue.create('sendMessage', dataSendMessage).save((err) ->
        if !err
          log "[kue.coffee] {trackHandler} (OK) Kue job id: #{job.id}."
        return
      )
      done()
      return

## Find Handler

    findHandler = (data, queue, done) ->
      {chat, text} = data
      if !chat?.id? or !text?
        errorText = "Error! [kue.coffee](findHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title:   "Send Message: '#{text}' to (#{chat.id})."
        type:    'sendMessage'
        chatId:  chat.id
        text:    text
      job = queue.create('sendMessage', dataSendMessage).save((err) ->
        if !err
          log "[kue.coffee] {findHandler} (OK) Kue job id: #{job.id}."
        return
      )
      done()
      return

## List Handler

    listHandler = (data, queue, done) ->
      {chat, text} = data
      if !chat?.id? or !text?
        errorText = "Error! [kue.coffee](listHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title:   "Send Message: '#{text}' to (#{chat.id})."
        type:    'sendMessage'
        chatId:  chat.id
        text:    text
      job = queue.create('sendMessage', dataSendMessage).save((err) ->
        if !err
          log "[kue.coffee] {listHandler} (OK) Kue job id: #{job.id}."
        return
      )
      done()
      return

## About Handler

    aboutHandler = (data, queue, done) ->
      {chat, text} = data
      if !chat?.id? or !text?
        errorText = "Error! [kue.coffee](aboutHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title:   "Send Message: '#{text}' to (#{chat.id})."
        type:    'sendMessage'
        chatId:  chat.id
        text:    text
      job = queue.create('sendMessage', dataSendMessage).save((err) ->
        if !err
          log "[kue.coffee] {aboutHandler} (OK) Kue job id: #{job.id}."
        return
      )
      done()
      return

## Config Handler

    configHandler = (data, queue, done) ->
      {chat, text} = data
      if !chat?.id? or !text?
        errorText = "Error! [kue.coffee](configHandler) Faild to send text."
        log errorText
        return done(new Error(errorText))
      dataSendMessage =
        title:   "Send Message: '#{text}' to (#{chat.id})."
        type:    'sendMessage'
        chatId:  chat.id
        text:    text
      job = queue.create('sendMessage', dataSendMessage).save((err) ->
        if !err
          log "[kue.coffee] {configHandler} (OK) Kue job id: #{job.id}."
        return
      )
      done()
      return

# Class StartController

    class StartController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      startHandler: ($) ->
        type    = 'start'
        _options =
          attempts: 5
          priority: 'high'
          delay: 10
        data    =
          text: startText
          chat: $.message.chat
          options: _options
        job = @queue.create(type, data).save((err) ->
          if !err
            log "[StartController] Kue job id: #{job.id}."
          return
        )
      @property 'routes',
        get: -> 'startCommand': 'startHandler'

## Class HelpController

    class HelpController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      helpHandler: ($) ->
        type    = 'help'
        _options =
          attempts: 5
          priority: 'high'
          delay: 10
        data    =
          text: helpText
          chat: $.message.chat
          options: _options
        job = @queue.create(type, data).save((err) ->
          if !err
            log "[HelpController] Kue job id: #{job.id}."
          return
        )
      @property 'routes',
        get: -> 'helpCommand': 'helpHandler'

## Class

    class TrackController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      trackHandler: ($) ->
        {message} =  $
        form =
          link:
            q: 'Link for tracking:'
            error: 'Sorry, wrong input, send only one correct link.'
            validator: (message, callback) ->
              {text, entities, chat} = message
              attachments = _.map entities, (item) ->
                {type, offset, length} = item
                if type is 'url'
                  {url: text[offset..offset+length]}
              if attachments?[0]?.url? and attachments.length is 1
                callback true, attachments
              else
                callback false
        $.runForm form, (result) =>
          {url} = result.link[0]
          type    = 'track'
          _options =
            attempts: 5
            priority: 'high'
            delay: 10
          data    =
            text: url
            chat: $.message.chat
            options: _options
          job = @queue.create(type, data).save((err) ->
            if !err
              log "[HelpController] Kue job id: #{job.id}."
            return
          )
      @property 'routes',
        get: -> 'trackCommand': 'trackHandler'

## Class FindController

    class FindController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      findHandler: ($) ->
        type    = 'find'
        options =
          attempts: 5
          priority: 'high'
          delay: 10
        data    =
          text: 'Error! Try /find later.'
          chat: $.message.chat
          options: _options
        job = @queue.create(type, data).save((err) ->
          if !err
            log "[HelpController] Kue job id: #{job.id}."
          return
        )
      @property 'routes',
        get: -> 'findCommand': 'findHandler'

## Class ListController

    class ListController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      listHandler: ($) ->
        type    = 'list'
        _options =
          attempts: 5
          priority: 'high'
          delay: 10
        data    =
          text: 'Error! Try /list later.'
          chat: $.message.chat
          options: _options
        job = @queue.create(type, data).save((err) ->
          if !err
            log "[HelpController] Kue job id: #{job.id}."
          return
        )
      @property 'routes',
        get: -> 'listCommand': 'listHandler'


## Class AboutController

    class AboutController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      aboutHandler: ($) ->
        type    = 'about'
        _options =
          attempts: 5
          priority: 'high'
          delay: 10
        data    =
          text: aboutText
          chat: $.message.chat
          options: _options
        job = @queue.create(type, data).save((err) ->
          if !err
            log "[HelpController] Kue job id: #{job.id}."
          return
        )
      @property 'routes',
        get: -> 'aboutCommand': 'aboutHandler'


## Class ConfigController

    class ConfigController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      configHandler: ($) ->
        type    = 'config'
        _options =
          attempts: 5
          priority: 'high'
          delay: 10
        data    =
          text: 'Error! Try /config later.'
          chat: $.message.chat
          options: _options
        job = @queue.create(type, data).save((err) ->
          if !err
            log "[HelpController] Kue job id: #{job.id}."
          return
        )
      @property 'routes',
        get: -> 'configCommand': 'configHandler'

## Class OtherwiseController

    class OtherwiseController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      handle: ($) ->
        $.sendMessage 'Unknown commands. Try /help.'
        return

## Exports functions & constants

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
    module.exports.startHandler        = startHandler
    module.exports.helpHandler         = helpHandler
    module.exports.trackHandler        = trackHandler
    module.exports.findHandler         = findHandler
    module.exports.listHandler         = listHandler
    module.exports.aboutHandler        = aboutHandler
    module.exports.configHandler       = configHandler
    module.exports.KueJobHelper        = KueJobHelper
    module.exports.sendMessage         = sendMessage
    module.exports.StartController     = StartController
    module.exports.HelpController      = HelpController
    module.exports.TrackController     = TrackController
    module.exports.FindController      = FindController
    module.exports.ListController      = ListController
    module.exports.AboutController     = AboutController
    module.exports.ConfigController    = ConfigController
    module.exports.OtherwiseController = OtherwiseController

## More: [undertherules](https://github.com/caffellatte/undertherules)
