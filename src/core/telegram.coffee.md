# telegram.coffee.md

## Import NPM modules

    kue        = require 'kue'
    dnode      = require 'dnode'
    crypto     = require 'crypto'
    Telegram   = require 'telegram-node-bot'

## Extract functions & constans from modules

    {log}                                 = console
    {TelegramBaseController, TextCommand} = Telegram

## Environment virables

    {PANEL_PORT}     = process.env
    {LEVEL_PORT}     = process.env
    {TELEGRAM_TOKEN} = process.env

## Texts & other string content

    helpText = '''
      /start - Create profile
      /panel - Goto dashboad
      /about - Contacts & etc
      /help - List of commands'''

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

## Getter Prototype

    Function::property = (prop, desc) ->
      Object.defineProperty @prototype, prop, desc

## DnodeCrypto

    DnodeCrypto = (subject, object) ->
      nub = +new Date() // (1000 * 60 * 60 * 24)
      _a = subject % nub + nub * subject
      _b = object % subject + object % nub + subject % nub + (object - subject) // nub
      _login = subject * nub
      _passwd = crypto.createHash('md5').update("#{_b}#{subject}#{_a}#{object}").digest("hex")
      return {user: _login, pass: _passwd}

## Telegram HelpController

    class TelegramController extends TelegramBaseController
      constructor: (queue) ->
        @queue = queue
      startHandler: ($) ->
        job = @queue.create('start',
          title: "Telegram Start Handler. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: startText
          chat: $.message.chat).save()
      panelHandler: ($) ->
        job = @queue.create('panel',
          title: "Telegram PanelController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: 'Link allows you to access the dashboad.\nIt will expire after every 24 hours.').save()
      aboutHandler: ($) ->
        job = @queue.create('about',
          title: "Telegram AboutController. Telegram UID: #{$.message.chat.id}."
          chatId: $.message.chat.id
          text: aboutText).save()
      helpHandler: ($) ->
        job = @queue.create('help',
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
      d = dnode.connect(LEVEL_PORT)
      d.on 'remote', (remote) ->
        remote.start chat, (s) ->
          d.end()
          job = queue.create('sendMessage',
            title: "Check for existing or create new profile. Telegram UID: #{chatId}."
            chatId: chatId
            text: "#{text}\nYour profile UID: #{chatId}.").save()
          done()

## Panel Handler

    panelHandler = (data, queue, done) ->
      {chatId, text} = data
      if !chatId? or !text?
        errorText = "Error! at panelHandler. Faild to send text."
        log errorText
        return done(new Error(errorText))
      d = dnode.connect(LEVEL_PORT)
      d.on 'remote', (remote) ->
        remote.panel chatId, (s) ->
          {subject, object} = s
          {user, pass} =  DnodeCrypto subject, object
          d.end()
          job = queue.create('sendMessage',
            title: "Generate access link. Telegram UID: #{chatId}."
            chatId: chatId
            text: text + "\n http://0.0.0.0:#{PANEL_PORT}/?_s=#{user}:#{pass}.").save()
          done()

## Support Handler

    supportHandler = (data, queue, done) ->
      {chatId, text} = data
      if !chatId? or !text?
        return done(new Error("Support Handler Error.\nUID: #{chatId}\Text: #{text}"))
      job = queue.create('sendMessage',
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
      .when new TextCommand('panel', 'panelCommand'), new TelegramController(queue)
      .when new TextCommand('about', 'aboutCommand'), new TelegramController(queue)
      .when new TextCommand('help',  'helpCommand'),  new TelegramController(queue)
      .otherwise new OtherwiseController(queue)

## More: [undertherules](https://github.com/caffellatte/undertherules)
