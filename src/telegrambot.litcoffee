telegrambot.litcoffee
=====================

## Import NPM modules

    kue         = require 'kue'
    TelegramBot = require 'telegram-node-bot'

## Extract functions & constans from modules

    {log} = console
    {TelegramBaseController, TextCommand, InputFile} = TelegramBot

## Environment virables


    {VK_SCOPE, VK_REDIRECT_HOST, VK_REDIRECT_PORT} = process.env
    {BOT_PANEL_HOST, BOT_PANEL_PORT, TELEGRAM_TOKEN} = process.env
    {VK_CLIENT_ID, VK_CLIENT_SECRET, VK_DISPLAY, VK_VERSION} = process.env

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

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
      Usage: /help. Contacts: /about. Tokens: /auth. Dashboard: /login.'''
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

## TelegramController

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

## Create Telegram instance interface

    tg = new TelegramBot.Telegram TELEGRAM_TOKEN,
      workers: 2
      webAdmin:
        port: BOT_PANEL_PORT,
        host: BOT_PANEL_HOST

## Telegram Bot Router

    tg.router
      .when new TextCommand('start', 'startCommand'), new TelegramController()
      .when new TextCommand('login', 'panelCommand'), new TelegramController()
      .when new TextCommand('about', 'aboutCommand'), new TelegramController()
      .when new TextCommand('auth',  'authCommand'),  new TelegramController()
      .when new TextCommand('help',  'helpCommand'),  new TelegramController()
      .otherwise new OtherwiseController()

## Telegram onMaster (Queue process handlers)

    tg.onMaster () ->
      log '\tBot: http://t.me/UnderTheRulesBot'

### Queue 'sendMessage' process

      queue.process 'sendMessage', (job, done) ->
        {chatId, text} = job.data
        if !chatId? or !text?
          return Error("Error! [sendMessage]")
        tg.api.sendMessage chatId, text
        done()

### Queue 'sendDocument' process

      queue.process 'sendDocument', (job, done) ->
        {chatId, filePath} = job.data
        if !chatId? or !filePath?
          return Error("Error! [sendDocument]")
        tg.api.sendDocument chatId, InputFile.byFilePath(filePath)
        done()
