# kue.coffee.md

Kue job (task) processing that include the most part of bakcground work.

## Import NPM modules

    _           = require 'lodash'
    fs          = require 'fs-extra'
    os          = require 'os'
    kue         = require 'kue'
    url         = require 'url'
    http        = require 'http'
    dnode       = require 'dnode'
    level       = require 'levelup'
    crypto      = require 'crypto'
    natural     = require 'natural'
    cluster     = require 'cluster'
    request     = require 'request'
    levelgraph  = require 'levelgraph'
    querystring = require 'querystring'
    TelegramBot = require 'telegram-node-bot'

## Extract functions & constans from modules

    {log}              = console
    {exec}             = require 'child_process'
    {stringify, parse} = JSON
    {TelegramBaseController, TextCommand}             = TelegramBot
    {removeSync, mkdirsSync, copySync, ensureDirSync} = fs

## Environment virables

    {
      KUE_PORT,
      CORE_DIR,
      LEVEL_DIR,
      STATIC_DIR,
      HTDOCS_DIR,
      LEVEL_DIR,
      LEVEL_PORT,
      PANEL_PORT,
      PANEL_HOST,
      VK_CLIENT_ID,
      VK_REDIRECT_HOST,
      VK_REDIRECT_PORT,
      VK_DISPLAY,
      VK_SCOPE,
      VK_VERSION,
      VK_CLIENT_SECRET,
      VK_VERSION,
      STATIC_DIR,
      PANEL_PORT,
      PANEL_HOST,
      BOT_PANEL_HOST,
      BOT_PANEL_PORT,
      TELEGRAM_TOKEN
    }   = process.env
    numCPUs            = require('os').cpus().length - 2

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

## Telegram texts

    helpText = '''
      /help - List of commands
      /auth - Authorization links
      /start - Create user's profile
      /login - Log in to your dashboad
      /about - Feedback and complaints'''
    startText = '''
      Flexible environment for social network analysis (SNA).
      Software provides full-cycle of retrieving and subsequent
      processing data from the social networks.
      Usage: /help. Contacts: /about. Dashboard: /login.'''
    aboutText = '''
      Undertherules, MIT license
      Copyright (c) 2016 Mikhail G. Lutsenko
      Email: m.g.lutsenko@gmail.com
      Telegram: @ltsnk'''
    authText = """
      Authorization via Social Networks"""


## Getter Prototype

    Function::property = (prop, desc) ->
      Object.defineProperty @prototype, prop, desc

## Telegram HelpController

    class TelegramController extends TelegramBaseController
      constructor: () ->
      startHandler: ($) ->
        queue.create('start',
          title: "Telegram Start Handler. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: startText
          chat: $.message.chat).save()
      panelHandler: ($) ->
        queue.create('panel',
          title: "Telegram PanelController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: 'Link allows you to access the dashboad.\nIt will expire after every 24 hours.').save()
      aboutHandler: ($) ->
        queue.create('support',
          title: "Telegram AboutController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: aboutText).save()
      helpHandler: ($) ->
        queue.create('support',
          title: "Telegram HelpController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: helpText).save()
      authHandler: ($) ->
        vkAuthLnk = "vk: https://oauth.vk.com/authorize?client_id=#{VK_CLIENT_ID}&display=#{VK_DISPLAY}&redirect_uri=http://#{VK_REDIRECT_HOST}:#{VK_REDIRECT_PORT}/&scope=#{VK_SCOPE}&response_type=code&v=#{VK_VERSION}&state=vk"
        text = "#{authText}\n#{vkAuthLnk},#{$.message.chat.id}"
        queue.create('support',
          title: "Telegram AuthController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: text).save()
      @property 'routes',
        get: ->
          'authCommand':  'authHandler'
          'helpCommand':  'helpHandler'
          'aboutCommand': 'aboutHandler'
          'startCommand': 'startHandler'
          'panelCommand': 'panelHandler'

## Class OtherwiseController

    class OtherwiseController extends TelegramBaseController
      constructor: () ->
      handle: ($) ->
        queue.create('mediaChecker',
          title: "mediaChecker Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: $.message.text).save()

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

## Create Telegram instance interface

    tg = new TelegramBot.Telegram TELEGRAM_TOKEN,
      workers: 1
      webAdmin:
        port: BOT_PANEL_PORT,
        host: BOT_PANEL_HOST

## Telegram onMaster (Queue process handlers)

    tg.onMaster () ->

### Queue 'sendMessage' process

      queue.process 'sendMessage', (job, done) ->
        {chatId, text} = job.data
        if !chatId? or !text?
          return Error("Error! [sendMessage] Faild to send messsage.")
        tg.api.sendMessage chatId, text
        done()

      log '\nTelegram: http://t.me/UnderTheRulesBot'

## Telegram Bot Router

    tg.router
      .when new TextCommand('start', 'startCommand'), new TelegramController()
      .when new TextCommand('login', 'panelCommand'), new TelegramController()
      .when new TextCommand('about', 'aboutCommand'), new TelegramController()
      .when new TextCommand('auth',  'authCommand'),  new TelegramController()
      .when new TextCommand('help',  'helpCommand'),  new TelegramController()
      .otherwise new OtherwiseController()

## Define link tokenizer

    tokenizer = new natural.RegexpTokenizer({pattern: /(https?:\/\/[^\s]+)/g})

## Cluster Master

    if cluster.isMaster

## Start Kue

      kue.app.set('title', 'Under The Rules')
      kue.app.listen KUE_PORT, ->
        log("Priority queue (cluster) started.\nWeb: http://0.0.0.0:#{KUE_PORT}.")
        kue.Job.rangeByState 'complete', 0, 100000, 'asc', (err, jobs) ->
          jobs.forEach (job) ->
            job.remove ->
              console.log 'removed ', job.id



## Create Level Dir folder

      ensureDirSync LEVEL_DIR

## Level. Initializing users, tokens, history

      users   = levelgraph(level(LEVEL_DIR + '/users'))
      tokens  = levelgraph(level(LEVEL_DIR + '/tokens'))
      history = levelgraph(level(LEVEL_DIR + '/history'))

###  Queue **CreateUser** process

      queue.process 'CreateUser', (job, done) ->
        {chatId, chat, text} = job.data
        {id, type, username, first_name, last_name} = chat
        triple =
          subject: id
          predicate: 'start'
          object: +new Date()
          type: type
          username: username
          first_name: first_name
          last_name: last_name
        users.get { subject: id, predicate: 'start' }, (err, list) =>
          if err
            done(err)
          else
            switch list.length
              when 1
                job = queue.create('sendMessage',
                  title: "Profile already exists. ID: #{chatId}."
                  chatId: chatId
                  text: "#{text}Profile already exists ID: #{chatId}").save()
                done()
              when 0
                users.put triple, (err) ->
                  if not err
                    job = queue.create('sendMessage',
                      title: "Create new profile. ID: #{chatId}."
                      chatId: chatId
                      text: "#{text}Create new profile. ID: #{chatId}.").save()
                    done()
                  else
                    done(err)
              else
                done('err')

###  Queue **CreateSession** process

      queue.process 'CreateSession', (job, done) ->
        {chatId, text} = job.data
        users.get { subject: chatId, predicate: 'start' }, (err, list) ->
          if err
            done(err)
          else
            if list.length is 1
              {predicate, object, type, username, first_name, last_name} = list[0]
              pass = crypto.createHash('md5').update("#{object}").digest("hex")
              job = queue.create('sendMessage',
                title: "Generate access link. Telegram UID: #{chatId}."
                chatId: chatId
                text: text + "http://#{PANEL_HOST}:#{PANEL_PORT}/?_s=#{chatId}:#{pass}").save()
              done()
            else
              done('err')

###  Queue **AuthenticateUser** process

      queue.process 'AuthenticateUser', (job, done) ->
        {chatId} = job.data
        users.get { subject: chatId, predicate: 'start' }, (err, list) ->
          if err
            done(err)
          else
            if list.length is 1
              {subject, object, type, username, first_name, last_name} = list[0]
              pass = crypto.createHash('md5').update("#{object}").digest("hex")
              done(null,
                user:subject,
                pass:pass,
                first_name:first_name,
                last_name:last_name,
                username:username,
                type:username
              )
            else
              done(err)

### Queue **SaveTokens** process

      queue.process 'SaveTokens', (job, done) ->
        {access_token, expires_in,user_id,email,chatId,first} = job.data
        log access_token, expires_in,user_id,email,chatId
        triple =
          subject: chatId
          predicate: expires_in
          object: user_id
          network: first
          email: email
          access_token: access_token
        tokens.put triple, (err) ->
          if err
            done(new Error("Error! SaveTokens. #{triple}"))
          else
            queue.create('sendMessage',
            title: "Send support text. Telegram UID: #{chatId}."
            chatId: chatId
            text: "Token saved.").save()
          done()

### Queue **GetTokens** process

      queue.process 'GetTokens', (job, done) ->
        {chatId} = job.data
        tokens.get { subject: chatId }, (err, list) =>
          if err
            done(err)
          else
            if list
              done(null, list)
            else
              done(err)

### **Clean** job list on exit

      exitHandler = (options, err) =>
        if err
          log err.stack
        if options.exit
          process.exit()
          return
        if options.cleanup
          log 'cleanup'

### Exiting
- *do something when app is closing*
- *catches ctrl+c event*
- *catches uncaught exceptions*

      process.on 'exit', exitHandler.bind(null, cleanup: true)
      process.on 'SIGINT', exitHandler.bind(null, exit: true)
      process.on 'uncaughtException', exitHandler.bind(null, exit: true)

## Cluster Worker

      i = 0
      while i < numCPUs
        cluster.fork()
        i++

    else

## Create HTTP Server for LevelDB

      LevelServer = http.createServer (req,res) ->
        res.setHeader('Content-Type', 'text/html')
        res.writeHead(200, {'Content-Type': 'text/plain'})
        res.end("ok\n\n.")

      LevelServer.listen LEVEL_PORT, ->
        log("""
        LevelGraph module successful started. Listen port: #{LEVEL_PORT}.
        Web: http://0.0.0.0:#{LEVEL_PORT}
        """)

## Create HTTP Server for Netwoks

      NetworksServer = http.createServer (req, res) ->
        parts = url.parse(req.url, true)
        {code, state} = parts.query
        if code and state
          [first, ..., last] = state.split(',')
          switch first
            when 'vk'
              chatId = last
              console.log(chatId)
              vkUrl  = 'https://oauth.vk.com/access_token?'
              vkUrl += "client_id=#{VK_CLIENT_ID}&client_secret=#{VK_CLIENT_SECRET}&"
              vkUrl += "redirect_uri=http://#{VK_REDIRECT_HOST}:#{VK_REDIRECT_PORT}/&"
              vkUrl +=  "code=#{code}"
              request vkUrl, (error, response, body) ->
                if !error and response.statusCode == 200
                  console.log body
                  {access_token, expires_in,user_id,email} = JSON.parse(body)
                  queue.create('SaveTokens',
                    title: "Send support text. Telegram UID: #{chatId}."
                    chatId: chatId,
                    access_token: access_token,
                    expires_in: expires_in,
                    user_id: user_id,
                    email: email
                    first: first).save()
                  # Seve to db
                  # res.end(body)
                  res.writeHead(302, {'Location': 'http://t.me/UnderTheRulesBot'})
                  res.end()
            else
              res.end(error)
        else
          {error, error_description} = parts.query
          res.end("#{error}. #{error_description}")

      NetworksServer.listen VK_REDIRECT_PORT*1, VK_REDIRECT_HOST, ->
        log("""
        Netwoks module successful started. Listen port: #{VK_REDIRECT_PORT}.
        Web: http://#{VK_REDIRECT_HOST}:#{VK_REDIRECT_PORT}
        """)

### Queue **coffeelint** handler

      queue.process 'coffeelint', (job, done) ->
        {files} = job.data
        command = 'coffeelint ' + "#{files.join(' ')}"
        exec command, (err, stdout, stderr) ->
          log(command)
          log(stdout, stderr)
          done()

### Queue **vkWallStatic** process

      queue.process 'vkWallStatic', (job, done) ->
        {chatId, name, items} = job.data
        filename = "#{STATIC_DIR}/files/#{name}-wall-#{items.length}.csv"
        fs.writeFileSync filename, "id;from_id;owner_id;date;post_type;comments;likes;reposts\n"
        [first, ..., last] = items
        rows = ''
        for item in items
          {id,from_id,owner_id,date,post_type,comments,likes,reposts} = item
          rows += "#{id};#{from_id};#{owner_id};#{new Date(date*1000)};#{post_type};#{comments.count};#{likes.count};#{reposts.count}\n"
          if id is last.id
            fs.appendFileSync filename, rows
            done(null, "http://#{PANEL_HOST}:#{PANEL_PORT}/files/#{name}-wall-#{items.length}.csv")

### Queue **vkMediaScraper** process

      queue.process 'vkMediaScraper', (job, done) ->
        {chatId, method, params, items} = job.data
        requestUrl = "https://api.vk.com/method/#{method}?#{querystring.stringify(params)}"
        request requestUrl, (error, response, body) =>
          if not error and response.statusCode is 200
            body = JSON.parse(body)
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
                queue.create('sendMessage',
                  title: "vkWallStaticJob Telegram UID: #{chatId}.",
                  chatId: chatId,
                  text: result).save()
            done()
          else
            done(error)
        done()

### Queue **mediaAnalyzer** process

      queue.process 'mediaAnalyzer', (job, done) ->
        {chatId, href, host, path} = job.data
        GetTokensJob = queue.create('GetTokens',
          title: 'Get Tokens',
          chatId: chatId).save()
        GetTokensJob.on 'complete', (result) ->
          {access_token} = result[0]
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

### Queue **mediaChecker** process

      queue.process 'mediaChecker', (job, done) ->
        {chatId, text} = job.data
        rawLinks = tokenizer.tokenize(text)
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

###  Queue **start** process

      queue.process 'start', (job, done) ->
        {chatId, text, chat} = job.data
        if !chatId? or !text? or !chat?
          return done(new Error("Start Handler Error.\nUID: #{chatId}\nText: #{text}\nData: #{chat}"))
        queue.create('CreateUser',
          title: "Create new profile. Telegram UID: #{chatId}.",
          chat: chat,
          chatId: chatId,
          text: "#{text}\n\n").save()
        done()

###  Queue **panel** process

      queue.process 'panel', (job, done) ->
        {chatId, text} = job.data
        if !chatId? or !text?
          return done(new Error("Error! at panelHandler. Faild to send text."))
        queue.create('CreateSession',
          title: "Create new session. Telegram UID: #{chatId}.",
          chatId: chatId,
          text: "#{text}\n\n").save()
        done()

###  Queue **support** process

      queue.process 'support', (job, done) ->
        {chatId, text} = job.data
        if !chatId? or !text?
          return done(new Error("Support Handler Error.\nUID: #{chatId}\Text: #{text}"))
        queue.create('sendMessage',
          title: "Send support text. Telegram UID: #{chatId}."
          chatId: chatId
          text: text).save()
        done()
