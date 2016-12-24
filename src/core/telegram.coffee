#                                                        =======================
#                                                        | src/telegram.coffee |
#                                                        =======================

### ============================================================= ###
# Using software https://www.npmjs.com/package/telegram-node-bot    #
### ============================================================= ###

# =============================== |
# https://telegram.me/BotFather   |
# =============================== |

### ========================== ###
{                                #
  KUE_PORT,                      #
}                 = process.env  #
### ========================== ###

### =============== ###
{log}    = console    #
### =============== ###

### ======================================================== ###
fs       = require 'fs'                    # ~~~~~~~~~~~~~~~~~ #
request  = require 'request'               # NPM               #
_        = require 'lodash'                # http://npmjs.com  #
helpers  = require './helpers.coffee'      # ~~~~~~~~~~~~~~~~~ #
Telegram = require 'telegram-node-bot'                         #
translit = require 'translitit-cyrillic-russian-to-latin'      #
### ======================================================== ###

### ===================================================== ###
{                             # Extract BaseController,     #
  TelegramBaseController,     # TextCommand  objects from   #
# TextCommand                 # Telegram class              #
}                = Telegram   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
### ===================================================== ###

### ======================================================== ###
{                             # Extract helpers functions      #
  helpText,                                                    #
  startText,                                                   #
  aboutText,                                                   #
  Formatter,                                                   #
  KueJobHelper,                                                #
  DatePrettyString                                             #
}                = helpers                                     #
### ======================================================== ###

### ======================================================== ###
kueJob = new KueJobHelper()
### ======================================================== ###

### ======================================================== ###
Function::property = (prop, desc) ->               # Getter    #
  Object.defineProperty @prototype, prop, desc     # prototype #
### ======================================================== ###

### ==================================================== ###
class StartController extends TelegramBaseController       #
  constructor: () ->                                       #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  startHandler: ($) ->                                     #
    type    = 'start'                                      #
    data    =                                              #
      text: startText                                      #
      chat: $.message.chat                                 #
    options =                                              #
      attempts: 5                                          #
      priority: 'high'                                     #
      delay: 10                                            #
    kueJob.create type, data, options                      #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  @property 'routes',                                      #
    get: -> 'startCommand': 'startHandler'                 #
### ==================================================== ###

### ==================================================== ###
class HelpController extends TelegramBaseController        #
  constructor: () ->                                       #
  helpHandler: ($) ->                                      #
    type    = 'help'                                       #
    data    =                                              #
      text: helpText                                       #
      chat: $.message.chat                                 #
    options =                                              #
      attempts: 5                                          #
      priority: 'high'                                     #
      delay: 10                                            #
    kueJob.create type, data, options                      #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  @property 'routes',                                      #
    get: -> 'helpCommand': 'helpHandler'                   #
### ==================================================== ###

### =================================================================== ###
class TrackController extends TelegramBaseController                      #
  constructor: () ->                                                      #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  trackHandler: ($) ->                                                    #
    {message} =  $                                                        #
    form =                                                                #
      link:                                                               #
        q: 'Link for tracking:'                                           #
        error: 'Sorry, wrong input, send only one correct link.'          #
        validator: (message, callback) ->                                 #
          {text, entities, chat} = message                                #
          attachments = _.map entities, (item) ->                         #
            {type, offset, length} = item                                 #
            if type is 'url'                                              #
              {url: text[offset..offset+length]}                          #
          if attachments?[0]?.url? and attachments.length is 1            #
            callback true, attachments                                    #
          else                                                            #
            callback false                                                #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
    $.runForm form, (result) ->                                           #
      {url} = result.link[0]                                              #
      type    = 'track'                                                   #
      data    =                                                           #
        text: url                                                         #
        chat: $.message.chat                                              #
      options =                                                           #
        attempts: 5                                                       #
        priority: 'high'                                                  #
        delay: 10                                                         #
      kueJob.create type, data, options                                   #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  @property 'routes',                                                     #
    get: -> 'trackCommand': 'trackHandler'                                #
### =================================================================== ###

### ======================================================== ###
class FindController extends TelegramBaseController            #
  constructor: () ->                                           #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  findHandler: ($) ->                                          #
    type    = 'find'                                           #
    data    =                                                  #
      text: 'Error! Try /find later.'                          #
      chat: $.message.chat                                     #
    options =                                                  #
      attempts: 5                                              #
      priority: 'high'                                         #
      delay: 10                                                #
    kueJob.create type, data, options                          #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  @property 'routes',                                          #
    get: -> 'findCommand': 'findHandler'                       #
### ======================================================== ###

### ======================================================== ###
class ListController extends TelegramBaseController            #
  constructor: () ->                                           #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  listHandler: ($) ->                                          #
    type    = 'list'                                           #
    data    =                                                  #
      text: 'Error! Try /list later.'                          #
      chat: $.message.chat                                     #
    options =                                                  #
      attempts: 5                                              #
      priority: 'high'                                         #
      delay: 10                                                #
    kueJob.create type, data, options                          #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  @property 'routes',                                          #
    get: -> 'listCommand': 'listHandler'                       #
### ======================================================== ###

### ======================================================== ###
class AboutController extends TelegramBaseController           #
  constructor: () ->                                           #
  aboutHandler: ($) ->                                         #
    type    = 'about'                                          #
    data    =                                                  #
      text: aboutText                                          #
      chat: $.message.chat                                     #
    options =                                                  #
      attempts: 5                                              #
      priority: 'high'                                         #
      delay: 10                                                #
    kueJob.create type, data, options                          #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  @property 'routes',                                          #
    get: -> 'aboutCommand': 'aboutHandler'                     #
### ======================================================== ###

### ======================================================== ###
class ConfigController extends TelegramBaseController          #
  constructor: () ->                                           #
  configHandler: ($) ->                                        #
    type    = 'config'                                         #
    data    =                                                  #
      text: 'Error! Try /config later.'                        #
      chat: $.message.chat                                     #
    options =                                                  #
      attempts: 5                                              #
      priority: 'high'                                         #
      delay: 10                                                #
    kueJob.create type, data, options                          #
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  @property 'routes',                                          #
    get: -> 'configCommand': 'configHandler'                   #
### ======================================================== ###


### ======================================================== ###
class OtherwiseController extends TelegramBaseController       #
  constructor: () ->                                           #
  handle: ($) ->                                               #
    $.sendMessage 'Unknown commands. Try /help.'               #
    return                                                     #
### ======================================================== ###

### ============================================================ ###
# Node.js, Require and Exports                                     #
# http://openmymind.net/2012/2/3/Node-Require-and-Exports/         #
module.exports.StartController     = StartController               #
module.exports.HelpController      = HelpController                #
module.exports.TrackController     = TrackController               #
module.exports.FindController      = FindController                #
module.exports.ListController      = ListController                #
module.exports.AboutController     = AboutController               #
module.exports.ConfigController    = ConfigController              #
module.exports.OtherwiseController = OtherwiseController           #
### ============================================================ ###

#     ===================================================================
#     | Copyright (c) 2016 Mikhail G. Lutsenko (m.g.lutsenko@gmail.com) |
#     |          https://github.com/caffellatte/undertherules           |
#     ===================================================================

    #
    # ### ======================================================================== ###
    # findHandler = (data, done) ->                                #  Find Handler   #
    #   {chat, text} = data                                        #  ~~~~~~~~~~~~~~ #
    #   if !chat?.id? or !text?                                                      #
    #     errorText = "Error! [kue.coffee](findHandler) Faild to send text."         #
    #     log errorText                                                              #
    #     return done(new Error(errorText))                                          #
    #   dataSendMessage =                                                            #
    #     title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    #     type:    'sendMessage'                                                     #
    #     chatId:  chat.id                                                           #
    #     text:    text                                                              #
    #   job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    #     if !err                                                                    #
    #       log "[kue.coffee] {findHandler} (OK) Kue job id: #{job.id}."             #
    #     return                                                                     #
    #   )                                                                            #
    #   done()                                                                       #
    #   return                                                                       #
    # ### ======================================================================== ###
    #
    # ### ======================================================================== ###
    # listHandler = (data, done) ->                                #  List Handler   #
    #   {chat, text} = data                                        #  ~~~~~~~~~~~~~~ #
    #   if !chat?.id? or !text?                                                      #
    #     errorText = "Error! [kue.coffee](listHandler) Faild to send text."         #
    #     log errorText                                                              #
    #     return done(new Error(errorText))                                          #
    #   dataSendMessage =                                                            #
    #     title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    #     type:    'sendMessage'                                                     #
    #     chatId:  chat.id                                                           #
    #     text:    text                                                              #
    #   job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    #     if !err                                                                    #
    #       log "[kue.coffee] {listHandler} (OK) Kue job id: #{job.id}."             #
    #     return                                                                     #
    #   )                                                                            #
    #   done()                                                                       #
    #   return                                                                       #
    # ### ======================================================================== ###
    #
    # ### ======================================================================== ###
    # aboutHandler = (data, done) ->                              #  About Handler   #
    #   {chat, text} = data                                       # ~~~~~~~~~~~~~~~~ #
    #   if !chat?.id? or !text?                                                      #
    #     errorText = "Error! [kue.coffee](aboutHandler) Faild to send text."        #
    #     log errorText                                                              #
    #     return done(new Error(errorText))                                          #
    #   dataSendMessage =                                                            #
    #     title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    #     type:    'sendMessage'                                                     #
    #     chatId:  chat.id                                                           #
    #     text:    text                                                              #
    #   job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    #     if !err                                                                    #
    #       log "[kue.coffee] {aboutHandler} (OK) Kue job id: #{job.id}."            #
    #     return                                                                     #
    #   )                                                                            #
    #   done()                                                                       #
    #   return                                                                       #
    # ### ======================================================================== ###
    #
    # ### ======================================================================== ###
    # configHandler = (data, done) ->                              #  Config Handler #
    #   {chat, text} = data                                        #  ~~~~~~~~~~~~~~ #
    #   if !chat?.id? or !text?                                                      #
    #     errorText = "Error! [kue.coffee](configHandler) Faild to send text."       #
    #     log errorText                                                              #
    #     return done(new Error(errorText))                                          #
    #   dataSendMessage =                                                            #
    #     title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    #     type:    'sendMessage'                                                     #
    #     chatId:  chat.id                                                           #
    #     text:    text                                                              #
    #   job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    #     if !err                                                                    #
    #       log "[kue.coffee] {configHandler} (OK) Kue job id: #{job.id}."           #
    #     return                                                                     #
    #   )                                                                            #
    #   done()                                                                       #
    #   return                                                                       #
    # ### ======================================================================== ###
    #
    # ### =============================== ###
    # queue             = kue.createQueue() #
    # ### =============================== ###
    #
    # ### ======================================================== ###
    # tg = new Telegram.Telegram TELEGRAM_TOKEN, {workers: 1} # tg #
    # ### ======================================================== ###

    return

### ======================================================================= ###
tg.router  # Telegram Bot Router declaration code                             #
  # start                                                                     #
  .when new TextCommand('start',  'startCommand'),   new StartController()    #
  # help                                                                      #
  .when new TextCommand('help',   'helpCommand'),    new HelpController()     #
  # track                                                                     #
  .when new TextCommand('track',  'trackCommand'),   new TrackController()    #
  # find                                                                      #
  .when new TextCommand('find',   'findCommand'),    new FindController()     #
  # list                                                                      #
  .when new TextCommand('list',   'listCommand'),    new ListController()     #
  # about                                                                     #
  .when new TextCommand('about',  'aboutCommand'),   new AboutController()    #
  # config                                                                    #
  .when new TextCommand('config', 'configCommand'),  new ConfigController()   #
  # otherwise                                                                 #
  .otherwise new OtherwiseController()                                        #
### ======================================================================= ###

#     ===================================================================
#     | Copyright (c) 2016 Mikhail G. Lutsenko (m.g.lutsenko@gmail.com) |
#     |        https://github.com/caffellatte/undertherules             |
#     ===================================================================
