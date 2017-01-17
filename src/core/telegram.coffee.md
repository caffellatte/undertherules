# telegram.coffee.md

## Import NPM modules

    kue        = require 'kue'
    dnode      = require 'dnode'
    Telegram   = require 'telegram-node-bot'

## Extract functions & constans from modules

    {log}                                 = console
    {TelegramBaseController, TextCommand} = Telegram

## Environment virables

    {PANEL_PORT}     = process.env
    {TELEGRAM_TOKEN} = process.env

## Texts & other string content

    helpText = '''
      /help - List of commands
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
      Start a conversation with the developer: @ltsnk'''

## Getter Prototype

    Function::property = (prop, desc) ->
      Object.defineProperty @prototype, prop, desc

## Telegram HelpController

    class TelegramController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      startHandler: ($) ->
        @queue.create('start',
          title: "Telegram Start Handler. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: startText
          chat: $.message.chat).save()
      panelHandler: ($) ->
        @queue.create('panel',
          title: "Telegram PanelController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: 'Link allows you to access the dashboad.\nIt will expire after every 24 hours.').save()
      aboutHandler: ($) ->
        @queue.create('about',
          title: "Telegram AboutController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: aboutText).save()
      helpHandler: ($) ->
        @queue.create('help',
          title: "Telegram HelpController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: helpText).save()
      @property 'routes',
        get: ->
          'helpCommand':  'helpHandler'
          'aboutCommand': 'aboutHandler'
          'startCommand': 'startHandler'
          'panelCommand': 'panelHandler'

## Class OtherwiseController

    class OtherwiseController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      handle: ($) ->
        $.sendMessage 'Unknown command. See list of commands: /help.'

## Start Handler

    startHandler = (data, queue, done) ->
      {chatId, text, chat} = data
      if !chatId? or !text? or !chat?
        return done(new Error("Start Handler Error.\nUID: #{chatId}\nText: #{text}\nData: #{chat}"))
      queue.create('CreateUser',
        title: "Create new profile. Telegram UID: #{chatId}.",
        chat: chat,
        chatId: chatId,
        text: "#{text}\n\n").save()
      done()

## Panel Handler

    panelHandler = (data, queue, done) ->
      {chatId, text} = data
      if !chatId? or !text?
        errorText = "Error! at panelHandler. Faild to send text."
        log errorText
        return done(new Error(errorText))
      queue.create('CreateSession',
        title: "Create new session. Telegram UID: #{chatId}.",
        chatId: chatId,
        text: "#{text}\n\n").save()
      done()

## Support Handler

    supportHandler = (data, queue, done) ->
      {chatId, text} = data
      if !chatId? or !text?
        return done(new Error("Support Handler Error.\nUID: #{chatId}\Text: #{text}"))
      queue.create('sendMessage',
        title: "Send support text. Telegram UID: #{chatId}."
        chatId: chatId
        text: text).save()
      done()

## Create a queue instance for creating jobs

    queue = kue.createQueue()

###  Queue **start** process

    queue.process 'start', (job, done) ->
      startHandler job.data, queue, done

###  Queue **panel** process

    queue.process 'panel', (job, done) ->
      panelHandler job.data, queue, done

###  Queue **about** process

    queue.process 'about', (job, done) ->
      supportHandler job.data, queue, done

###  Queue **help** process

    queue.process 'help', (job, done) ->
      supportHandler  job.data, queue, done

## Create Telegram instance interface

    tg = new Telegram.Telegram TELEGRAM_TOKEN, {workers: 1}

## Telegram onMaster

    tg.onMaster () =>

### Queue process handlers

      queue.process 'sendMessage', (job, done) ->
        {chatId, text} = job.data
        if !chatId? or !text?
          log "Error! [sendMessage] Faild to send messsage: #{text} to #{chatId}."
          return Error("Error! [sendMessage] Faild to send messsage.")
        tg.api.sendMessage chatId, text
        done()

## Telegram Bot Router

    tg.router
      .when new TextCommand('start', 'startCommand'), new TelegramController(queue)
      .when new TextCommand('login', 'panelCommand'), new TelegramController(queue)
      .when new TextCommand('about', 'aboutCommand'), new TelegramController(queue)
      .when new TextCommand('help',  'helpCommand'),  new TelegramController(queue)
      .otherwise new OtherwiseController(queue)
