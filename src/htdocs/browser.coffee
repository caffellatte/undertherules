# telegram.coffee

# Modules
# kue         = require('kue')
# TelegramBot = require('telegram-node-bot')

# Functions
# {TelegramBaseController, TextCommand, InputFile} = TelegramBot

# Environment
# {VK_SCOPE, PANEL_HOST, PANEL_PORT} = process.env
# {BOT_PANEL_HOST, BOT_PANEL_PORT, TELEGRAM_TOKEN} = process.env
# {VK_CLIENT_ID, VK_CLIENT_SECRET, VK_DISPLAY, VK_VERSION} = process.env
# VK_REDIRECT_HOST = PANEL_HOST
# VK_REDIRECT_PORT = PANEL_PORT
# Queue
# queue = kue.createQueue()

# Texts
# helpText = '''
#   /help - List of commands
#   /auth - Authorization links
#   /start - Create user's profile
#   /login - Log in to your dashboad
#   /about - Feedback and complaints'''
# startText = '''
#   Flexible environment for social network analysis (SNA).
#   Software provides full-cycle of retrieving and subsequent
#   processing data from the social networks.
#   Usage: /help. Contacts: /about. Tokens: /auth. Dashboard: /login.'''
# aboutText = '''
#   Undertherules, MIT license
#   Copyright (c) 2016 Mikhail G. Lutsenko
#   Email: m.g.lutsenko@gmail.com
#   Telegram: @ltsnk'''
# authText = '''
#   Authorization via Social Networks'''

# Getter
# Function::property = (prop, desc) ->
#   Object.defineProperty(@prototype, prop, desc)

# TelegramController
# class TelegramController extends TelegramBaseController
#   constructor: ->
#     return
#   startHandler: ($) ->
#     queue.create('start', {
#       title:"Telegram Start Handler. Telegram UID: #{$.message.chat.id}."
#       chatId:$.message.chat.id
#       text:startText
#       chat:$.message.chat
#     }).save()
#   panelHandler: ($) ->
#     text = 'Link allows you to access the dashboad.\n'
#     text += 'It will expire after every 24 hours.'
#     queue.create('panel', {
#       title:"Telegram PanelController. Telegram UID: #{$.message.chat.id}."
#       chatId:$.message.chat.id
#       text:text
#     }).save()
#   aboutHandler: ($) ->
#     queue.create('support', {
#       title:"Telegram AboutController. Telegram UID: #{$.message.chat.id}."
#       chatId:$.message.chat.id
#       text:aboutText
#     }).save()
#   helpHandler: ($) ->
#     queue.create('support', {
#       title:"Telegram HelpController. Telegram UID: #{$.message.chat.id}."
#       chatId:$.message.chat.id
#       text:helpText
#     }).save()
#   authHandler: ($) ->
#     vkAuthLnk= "vk: https://oauth.vk.com/authorize?client_id=#{VK_CLIENT_ID}&"
#     vkAuthLnk+="display=#{VK_DISPLAY}&redirect_uri=http://#{VK_REDIRECT_HOST}"
#     vkAuthLnk += ":#{VK_REDIRECT_PORT}/&scope=#{VK_SCOPE}&response_type=code&"
#     vkAuthLnk += "v=#{VK_VERSION}&state=vk"
#     text = "#{authText}\n#{vkAuthLnk},#{$.message.chat.id}"
#     queue.create('support', {
#       title:"Telegram AuthController. Telegram UID: #{$.message.chat.id}."
#       chatId:$.message.chat.id
#       text:text
#     }).save()
#   @property('routes', {
#     get: -> {
#       'authCommand':'authHandler'
#       'helpCommand':'helpHandler'
#       'aboutCommand':'aboutHandler'
#       'startCommand':'startHandler'
#       'panelCommand':'panelHandler'
#       }
#     }
#   )

# OtherwiseController
# class OtherwiseController extends TelegramBaseController
#   constructor: ->
#     return
#   handle:($) ->
#     queue.create('mediaChecker', {
#       title:"mediaChecker Telegram UID: #{$.message.chat.id}."
#       chatId:$.message.chat.id
#       text:$.message.text
#     }).save()

# Instance
# tg = new TelegramBot.Telegram(TELEGRAM_TOKEN, {
#   workers: 2
#   webAdmin: {
#     port: BOT_PANEL_PORT,
#     host: BOT_PANEL_HOST
#   }
# })

# Router
# tg.router
#   .when(new TextCommand('start', 'startCommand'), new TelegramController())
#   .when(new TextCommand('login', 'panelCommand'), new TelegramController())
#   .when(new TextCommand('about', 'aboutCommand'), new TelegramController())
#   .when(new TextCommand('auth',  'authCommand'),  new TelegramController())
#   .when(new TextCommand('help',  'helpCommand'),  new TelegramController())
#   .otherwise(new OtherwiseController())

# Master
# tg.onMaster( ->
#   console.log('Bot: http://t.me/UnderTheRulesBot')
## sendMessage
  # queue.process('sendMessage', (job, done) ->
  #   {chatId, text} = job.data
  #   if not chatId? or not text?
  #     return Error('Error at sending Message')
  #   tg.api.sendMessage(chatId, text)
  #   done()
  # )
## sendDocument
#   queue.process('sendDocument', (job, done) ->
#     {chatId, filePath} = job.data
#     if not chatId? or not filePath?
#       return Error('Error at sending Document!')
#     tg.api.sendDocument(chatId, InputFile.byFilePath(filePath))
#     done()
#   )
# )


### ************************************************************************ ###

# browser.coffee

# Modules
shoe        = require('shoe')
dnode       = require('dnode')
domready    = require('domready')
querystring = require('querystring')

# Functions
{parse} = require('url')

# Interface
class Interface
  constructor:(Dnode) ->
    @main       = document.getElementById('main')
    @input      = document.getElementById('input')
    @line       = document.getElementById('line')
    @output     = document.getElementById('output')
    @cli        = document.getElementById('cli')
    @bar        = document.getElementById('bar')
    @logoImg    = document.getElementById('logoImg')
    @logo       = document.getElementById('logo')
    @cliFlag    = 'none'
    @authFlag   = 'none'
    @line.onkeypress = @onkeypressCli
## *Authorization* & **Social Networks**
    Dnode.on('remote', (remote) =>
      @remote = remote
      {query} = parse(window.location.href)
      {code, state, _s} = querystring.parse(query)
      if code and state
        [first, ..., last] = state.split(',')
        switch first
          when 'vk'
            sendCodeData = {
              network:first
              code:code
              chatId:last
            }
            @remote.sendCode(sendCodeData, (s) ->
              console.log(s)
            )
      if _s?
        credentials = query.replace('_s=', '').split(':')
        @createCookie('user', credentials[0], 1)
        @createCookie('pass', credentials[1], 1)
      user = @readCookie('user') # or query.replace('_s=', '').split(':')[0]
      pass = @readCookie('pass') # or query.replace('_s=', '').split(':')[1]
      if user and pass
        @remote.auth(user, pass, (err, session) =>
          if err
            console.log(err)
            return Dnode.end()
          else
            @authorized(session)
        )
    )

  onkeypressCli:(event) =>
    {charCode} = event
    if charCode is 13
      {value} = @line
      @output.innerHTML += "<code class='req'>#{value}</code><br><br>"
      @line.value = ''
      @remote.search(value, (s) =>
        @output.innerHTML += "<code class='rep'>#{s}</code><br><br>"
      )
      return false
    return

  createCookie:(name, value, days) ->
    expires = ''
    if days
      date = new Date()
      date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000)
      expires = '; expires=' + date.toUTCString()
    document.cookie = name + '=' + value + expires + '; path=/'
    return

  readCookie:(name) ->
    nameEQ = name + '='
    ca = document.cookie.split(';')
    i = 0
    while i < ca.length
      c = ca[i]
      while c.charAt(0) is ' '
        c = c.substring(1, c.length)
      if c.indexOf(nameEQ) is 0
        return c.substring(nameEQ.length, c.length)
      i += 1
    null

  eraseCookie:(name) ->
    createCookie(name, '', -1)
    return

  authorized:(session) ->
    @session = session
    console.log(@session)



domready( ->
  stream = shoe('/dnode')
  Dnode  = dnode()
  Dnode.pipe(stream).pipe(Dnode)
  UI = new Interface(Dnode)
)
