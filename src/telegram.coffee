#                                                        =======================
#                                                        | src/telegram.coffee |
#                                                        =======================

### ========================== ###
{ KUE_PORT }      = process.env  #
{ log }           = console      #
### ========================== ###

### ================================== ###
fs       = require 'fs'                  #
request  = require 'request'             #
_        = require 'lodash'              #
helpers  = require './helpers.coffee'    #
Telegram = require 'telegram-node-bot'   #
### ================================== ###

### ================================ ###
{ TelegramBaseController } = Telegram  #
### ================================ ###

### ============================ ###
{ # Extract helpers functions      #
  helpText,                        #
  startText,                       #
  aboutText,                       #
  Formatter,                       #
  KueJobHelper,                    #
  DatePrettyString                 #
}                = helpers         #
### ============================ ###

### ========================== ###
kueJob = new KueJobHelper()      #
### ========================== ###

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
