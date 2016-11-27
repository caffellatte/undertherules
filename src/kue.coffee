#                            ======================
#                            |   src/kue.coffee   |
#                            ======================

### ========================== ###
{                                #
  KUE_PORT,                      #
  LEVEL_PORT,                    #
  TELEGRAM_TOKEN                 #
}                 = process.env  #
### ========================== ###

### ==================================== ###
net        = require 'net'                 #
kue        = require 'kue'                 #
path       = require 'path'                #
request    = require 'request'             #
cluster    = require 'cluster'             #
helpers    = require './helpers.coffee'    #
telegram   = require './telegram.coffee'   #
Telegram   = require 'telegram-node-bot'   #
multilevel = require 'multilevel'          #
### ==================================== ###

### ============================================== ###
clusterWorkerSize = require('os').cpus().length - 1  #
### ============================================== ###

### =================== ###
{log}     = console       #
{ parse } = require 'url' #
### =================== ###

### ============== ###
{                   #
  DatePrettyString, #
  Formatter,        #
} = helpers         #
### ============== ###

### ========================== ###
{                                #
  StartController                #
  HelpController                 #
  TrackController                #
  FindController                 #
  ListController                 #
  AboutController                #
  ConfigController               #
  OtherwiseController            #
} = telegram                     #
{ TextCommand } = Telegram       #
### ========================== ###

### =============================== ###
queue             = kue.createQueue() #
### =============================== ###

### ======================================================== ###
tg = new Telegram.Telegram TELEGRAM_TOKEN, {workers: 1} # tg   #
### ======================================================== ###

### ====================================================================== ###
sendMessage = (data, done) ->                       # Telegram Send  Message #
  {chatId, text} = data                                                      #
  if !chatId? or !text?                                                      #
    log "Error! [sendMessage] Faild to send messsage: #{text} to #{chatId}." #
    return done(new Error("Error! [sendMessage] Faild to send messsage."))   #
  tg.api.sendMessage chatId, text                                            #
  done()                                                                     #
  return                                                                     #
### ====================================================================== ###

### ======================================================================== ###
startHandler = (data, done) ->                              # Start Handler    #
  {chat, text} = data                                       # ~~~~~~~~~~~~~~~~ #
  if !chat?.id? or !text?                                                      #
    errorText = "Error! [kue.coffee](startHandler) Faild to send text."        #
    log errorText                                                              #
    return done(new Error(errorText))                                          #
  dataSendMessage =                                                            #
    title:   "Send Message: '#{text}' to (#{chat.id})"                         #
    chatId:  chat.id                                                           #
    text:    text                                                              #
  jobSendMessage  = queue.create('sendMessage', dataSendMessage).save((err) -> #
    if !err                                                                    #
      log "[kue.coffee] {startHandler} (OK) Kue job id: #{jobSendMessage.id}"  #
    return                                                                     #
  )                                                                            #
  done()                                                                       #
  return                                                                       #
### ======================================================================== ###

### ======================================================================== ###
helpHandler = (data, done) ->                              #  Help Handler     #
  {chat, text} = data                                      # ~~~~~~~~~~~~~~~~~ #
  if !chat?.id? or !text?                                                      #
    errorText = "Error! [kue.coffee](startHandler) Faild to send text."        #
    log errorText                                                              #
    return done(new Error(errorText))                                          #
  dataSendMessage =                                                            #
    title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    type:    'sendMessage'                                                     #
    chatId:   chat.id                                                          #
    text:    text                                                              #
  job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    if !err                                                                    #
      log "[kue.coffee] {helpHandler} (OK) Kue job id: #{job.id}"              #
    return                                                                     #
  )                                                                            #
  done()                                                                       #
  return                                                                       #
### ======================================================================== ###

### ======================================================================== ###
trackHandler = (data, done) ->                              #  Track Handler   #
  {chat, text} = data                                       #  ~~~~~~~~~~~~~~~ #
  if !chat?.id? or !text?                                                      #
    errorText = "Error! [kue.coffee](trackHandler) Faild to send text."        #
    log errorText                                                              #
    return done(new Error(errorText))                                          #
  dataSendMessage =                                                            #
    title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    type:    'sendMessage'                                                     #
    chatId:  chat.id                                                           #
    text:    text                                                              #
  job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    if !err                                                                    #
      log "[kue.coffee] {trackHandler} (OK) Kue job id: #{job.id}."            #
    return                                                                     #
  )                                                                            #
  done()                                                                       #
  return                                                                       #
### ======================================================================== ###

### ======================================================================== ###
findHandler = (data, done) ->                                #  Find Handler   #
  {chat, text} = data                                        #  ~~~~~~~~~~~~~~ #
  if !chat?.id? or !text?                                                      #
    errorText = "Error! [kue.coffee](findHandler) Faild to send text."         #
    log errorText                                                              #
    return done(new Error(errorText))                                          #
  dataSendMessage =                                                            #
    title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    type:    'sendMessage'                                                     #
    chatId:  chat.id                                                           #
    text:    text                                                              #
  job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    if !err                                                                    #
      log "[kue.coffee] {findHandler} (OK) Kue job id: #{job.id}."             #
    return                                                                     #
  )                                                                            #
  done()                                                                       #
  return                                                                       #
### ======================================================================== ###

### ======================================================================== ###
listHandler = (data, done) ->                                #  List Handler   #
  {chat, text} = data                                        #  ~~~~~~~~~~~~~~ #
  if !chat?.id? or !text?                                                      #
    errorText = "Error! [kue.coffee](listHandler) Faild to send text."         #
    log errorText                                                              #
    return done(new Error(errorText))                                          #
  dataSendMessage =                                                            #
    title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    type:    'sendMessage'                                                     #
    chatId:  chat.id                                                           #
    text:    text                                                              #
  job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    if !err                                                                    #
      log "[kue.coffee] {listHandler} (OK) Kue job id: #{job.id}."             #
    return                                                                     #
  )                                                                            #
  done()                                                                       #
  return                                                                       #
### ======================================================================== ###

### ======================================================================== ###
aboutHandler = (data, done) ->                              #  About Handler   #
  {chat, text} = data                                       # ~~~~~~~~~~~~~~~~ #
  if !chat?.id? or !text?                                                      #
    errorText = "Error! [kue.coffee](aboutHandler) Faild to send text."        #
    log errorText                                                              #
    return done(new Error(errorText))                                          #
  dataSendMessage =                                                            #
    title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    type:    'sendMessage'                                                     #
    chatId:  chat.id                                                           #
    text:    text                                                              #
  job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    if !err                                                                    #
      log "[kue.coffee] {aboutHandler} (OK) Kue job id: #{job.id}."            #
    return                                                                     #
  )                                                                            #
  done()                                                                       #
  return                                                                       #
### ======================================================================== ###

### ======================================================================== ###
configHandler = (data, done) ->                              #  Config Handler #
  {chat, text} = data                                        #  ~~~~~~~~~~~~~~ #
  if !chat?.id? or !text?                                                      #
    errorText = "Error! [kue.coffee](configHandler) Faild to send text."       #
    log errorText                                                              #
    return done(new Error(errorText))                                          #
  dataSendMessage =                                                            #
    title:   "Send Message: '#{text}' to (#{chat.id})."                        #
    type:    'sendMessage'                                                     #
    chatId:  chat.id                                                           #
    text:    text                                                              #
  job = queue.create('sendMessage', dataSendMessage).save((err) ->             #
    if !err                                                                    #
      log "[kue.coffee] {configHandler} (OK) Kue job id: #{job.id}."           #
    return                                                                     #
  )                                                                            #
  done()                                                                       #
  return                                                                       #
### ======================================================================== ###

### =================================================================== ###
if cluster.isMaster                                                       #
  kue.app.listen KUE_PORT, () -> log "Kue started at: #{KUE_PORT} port"   #
  i = 0                                                                   #
  while i < clusterWorkerSize                                             #
    cluster.fork()                                                        #
    i++                                                                   #
else                                                                      #
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  queue.process 'sendMessage', (job, done) -> sendMessage job.data, done  #
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  queue.process 'start',  (job, done) -> startHandler  job.data, done     #
  queue.process 'help',   (job, done) -> helpHandler   job.data, done     #
  queue.process 'track',  (job, done) -> trackHandler  job.data, done     #
  queue.process 'find',   (job, done) -> findHandler   job.data, done     #
  queue.process 'list',   (job, done) -> listHandler   job.data, done     #
  queue.process 'about',  (job, done) -> aboutHandler  job.data, done     #
  queue.process 'config', (job, done) -> configHandler job.data, done     #
### =================================================================== ###

### ======================================================================= ###
tg.router  # Telegram Bot Router declaration code                             #
  .when new TextCommand('start',  'startCommand'),   new StartController()    #
  .when new TextCommand('help',   'helpCommand'),    new HelpController()     #
  .when new TextCommand('track',  'trackCommand'),   new TrackController()    #
  .when new TextCommand('find',   'findCommand'),    new FindController()     #
  .when new TextCommand('list',   'listCommand'),    new ListController()     #
  .when new TextCommand('about',  'aboutCommand'),   new AboutController()    #
  .when new TextCommand('config', 'configCommand'),  new ConfigController()   #
  .otherwise new OtherwiseController()                                        #
### ======================================================================= ###

#     ===================================================================
#     | Copyright (c) 2016 Mikhail G. Lutsenko (m.g.lutsenko@gmail.com) |
#     |        https://github.com/caffellatte/undertherules             |
#     ===================================================================
