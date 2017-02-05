# telegram.coffee.md

## Import NPM modules

    kue        = require 'kue'
    Telegram   = require 'telegram-node-bot'

## Extract functions & constans from modules

    {TelegramBaseController, TextCommand} = Telegram

## Environment virables

    {BOT_PANEL_HOST}   = process.env
    {BOT_PANEL_PORT}   = process.env
    {TELEGRAM_TOKEN}   = process.env
    {VK_CLIENT_ID}     = process.env
    {VK_REDIRECT_HOST} = process.env
    {VK_REDIRECT_PORT} = process.env
    {VK_DISPLAY}       = process.env
    {VK_SCOPE}         = process.env
    {VK_VERSION}       = process.env

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

## Create a queue instance for creating jobs

    queue = kue.createQueue()

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

## Create Telegram instance interface

    tg = new Telegram.Telegram TELEGRAM_TOKEN,
      workers: 1
      webAdmin:
        port: BOT_PANEL_PORT,
        host: BOT_PANEL_HOST

## Telegram onMaster (Queue process handlers)

    tg.onMaster () =>
      console.log '\nTelegram: http://t.me/UnderTheRulesBot'
      queue.process 'sendMessage', (job, done) ->
        {chatId, text} = job.data
        if !chatId? or !text?
          return Error("Error! [sendMessage] Faild to send messsage.")
        tg.api.sendMessage chatId, text
        done()
## **Clean** static folder on exit

      exitHandler = (options, err) =>
        if err
          log err.stack
        if options.exit
          process.exit()
          return
        if options.cleanup
          console.log 'cleanup'

### **do something when app is closing**

      process.on 'exit', exitHandler.bind(null, cleanup: true)

### **catches ctrl+c event**

      process.on 'SIGINT', exitHandler.bind(null, exit: true)

### **catches uncaught exceptions**

      process.on 'uncaughtException', exitHandler.bind(null, exit: true)

## Telegram Bot Router

    tg.router
      .when new TextCommand('start', 'startCommand'), new TelegramController()
      .when new TextCommand('login', 'panelCommand'), new TelegramController()
      .when new TextCommand('about', 'aboutCommand'), new TelegramController()
      .when new TextCommand('auth',  'authCommand'),  new TelegramController()
      .when new TextCommand('help',  'helpCommand'),  new TelegramController()
      .otherwise new OtherwiseController()
