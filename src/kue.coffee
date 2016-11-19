#                            ======================
#                            |   src/kue.coffee   |
#                            ======================

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

### ============================================ ###
clusterWorkerSize = require('os').cpus().length - 1  #
### ============================================ ###

### =============== ###
{log}    = console    #
### =============== ###

### =============== ###
{                     #
  parse               #
} = require 'url'     #
### =============== ###

### =================================== ###
{                                         #
  DatePrettyString,                       #
  Formatter,                              #
} = helpers                               #
### =================================== ###

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
### ========================== ###

### ===================================================== ###
{                             # Extract BaseController,     #
# TelegramBaseController,     # TextCommand  objects from   #
  TextCommand                 # Telegram class              #
}                = Telegram   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
### ===================================================== ###

### ========================== ###
{                                #
  KUE_PORT,                      #
  LEVEL_PORT,                    #
  TELEGRAM_TOKEN                 #
}                 = process.env  #
### ========================== ###

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
  )
  # dataNewUser =
  #   title:   "New User: #{chatId}"
  #   chatId:   chatId                                                           #
  #   userData: data                                                             #
  # jobNewUser = queue.create('newUser', dataNewUser).save((err) ->              #
  #   if !err                                                                    #
  #     log "[kue.coffee] {helpHandler} (OK) Kue job id: #{jobNewUser.id}"       #
  #   return                                                                     #
  # )                                                                            #
  done()                                                                       #
  return                                                                       #
### ======================================================================== ###

newUser = (data, done) ->                       # Telegram New  User #
  {chat} = data.userData                                                      #
  {id, type, username, first_name, last_name} = chat
  chat.track = []
  chat.find  = []
  db = multilevel.client()
  con = net.connect LEVEL_PORT
  con.pipe(db.createRpcStream()).pipe con
  db.get id, (err, val) ->
    if err
      db.put id, chat, (err) ->
      if err
        return done(new Error(err))
        throw err
      done()
      return
    db.close()
    done()                                                                     #
    return                                                                     #
### ====================================================================== ###

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
  # if !chatId? or !url? or !type? or !network? or !mediaId?               #   #
  #   errorText = """
  #   Error! [kue.coffee](trackHandler).
  #   Faild to track #{type}, #{url} (#{network}) for #{chatId}.
  #   """                                                                        #
  #   log errorText                                                              #
  #   return done(new Error(errorText))                                          #
  # db = multilevel.client()
  # con = net.connect LEVEL_PORT
  # con.pipe(db.createRpcStream()).pipe con
  # db.get chatId, (err, val) ->
  #   if err
  #     return done(new Error(err))
  #     throw err
  #   val.track.push url
  #   db.put chatId, val, (err) ->
  #   if err
  #     return done(new Error(err))
  #     throw err
  #   done()
  #   return
  #   console.log val
  #   db.close()
  # requestTrackInstagramMedia =
  #   url: "http://localhost:#{KUE_PORT}/job"
  #   headers: 'Content-Type': 'application/json'
  #   method:  'POST'                                  #
  #   title:   "Track Handler '#{title}' to (#{chatId})"
  #   chatId:   chatId                                       #
  #   mediaId:  mediaId
  # jobType = "track#{network[0].toUpperCase()}#{network[1..]}#{type[0].toUpperCase()}#{type[1..]}Handler"
  # job = queue.create(jobType, requestTrackInstagramMedia).removeOnComplete( true ).save((err) ->      #
  #   if !err                                                                    #
  #     log "[kue.coffee] {trackHandler} (OK) Kue job id: #{job.id}"                            #
  #   return                                                                     #
  # )
  # requestDataSendMessage =
  #   url: "http://localhost:#{KUE_PORT}/job"
  #   headers: 'Content-Type': 'application/json'
  #   method:  'POST'                                  #
  #   title:   "Send Message: '#{title}' to (#{chatId})"
  #   type:    'sendMessage'                                #
  #   chatId:   chatId                                       #
  #   text:    "Instagram media id: #{mediaId}" # Stats
  # jobSendMessage = queue.create('sendMessage', requestDataSendMessage).save((err) ->      #
  #   if !err                                                                    #
  #     log "[kue.coffee] {sendMessage} (OK) Kue job id: #{jobSendMessage.id}"                            #
  #   return                                                                     #
  # )                                                                            #
  # done()                                                                       #
  # return                                                                       #
### ======================================================================== ###

### ====================================================================== ###
trackInstagramMediaHandler = (data, done) ->
  {chatId, mediaId} = data
  if !chatId? or !mediaId?               # create new user  #
    errorText = """
    Error! [kue.coffee](trackInstagramMediaHandler).
    Faild to track for #{chatId}.
    """                                                                        #
    log errorText                                                              #
    return done(new Error(errorText))                                          #
  uri = "https://www.instagram.com/p/#{mediaId}?__a=1"
  request uri, (error, response, body) ->
    if !error and response.statusCode is 200
      try
        data = JSON.parse body
      catch error
        log error
        return done(new Error(error))
      finally
        {media} = data
        {video_views, date, likes, comments} = media
        log likes: "#{likes.count}"
        # LOoooP! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        requestTrackInstagramMedia =
          url: "http://localhost:#{KUE_PORT}/job"
          headers: 'Content-Type': 'application/json'
          method:  'POST'                                  #
          title:   "[Track Loop] to (#{mediaId})"
          mediaId:  mediaId
          chatId:   chatId
        job = queue.create('trackInstagramMediaHandler', requestTrackInstagramMedia).removeOnComplete( true ).save((err) ->      #
          if !err                                                                    #
            log "[kue.coffee] {trackHandler} (OK) Kue job id: #{job.id}"                            #
          return                                                                     #
        ).delay(1000*60*1)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
        done()
        return
    else
      return done(new Error(error))
### ====================================================================== ###

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

### =============================== ###
queue             = kue.createQueue() #
### =============================== ###

### ======================================================== ###
tg = new Telegram.Telegram TELEGRAM_TOKEN, {workers: 1} # tg #
### ======================================================== ###

### ============================================================== ###
if cluster.isMaster                                                  #
  kue.app.listen KUE_PORT, () ->                                     #
    log "Kue started at port: #{KUE_PORT}..."                        #
    kue.Job.rangeByState 'complete', 0, 1000, 'asc', (err, jobs) ->  #
      jobs.forEach (job) ->                                          #
        job.remove ->                                                #
          console.log 'removed ', job.id                             #
          return                                                     #
        return                                                       #
      return                                                         #
  i = 0                                                              #
  while i < clusterWorkerSize                                        #
    cluster.fork()                                                   #
    i++                                                              #
else                                                                 #
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  queue.process 'sendMessage', (job, done) ->                        #
    sendMessage job.data, done                                       #
    return                                                           #
  queue.process 'newUser', (job, done) ->                            #
    newUser job.data, done                                           #
    return                                                           #
  queue.process 'trackInstagramMediaHandler', (job, done) ->         #
    trackInstagramMediaHandler job.data, done                        #
    return                                                           #
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  queue.process 'start', (job, done) ->                              #
    startHandler job.data, done                                      #
    return                                                           #
  queue.process 'help', (job, done) ->                               #
    helpHandler job.data, done                                       #
    return                                                           #
  queue.process 'track', (job, done) ->                              #
    trackHandler job.data, done                                      #
    return                                                           #
  queue.process 'find', (job, done) ->                               #
    findHandler job.data, done                                       #
    return                                                           #
  queue.process 'list', (job, done) ->                               #
    listHandler job.data, done                                       #
    return                                                           #
  queue.process 'about', (job, done) ->                              #
    aboutHandler job.data, done                                      #
    return                                                           #
  queue.process 'config', (job, done) ->                             #
    configHandler job.data, done                                     #
    return                                                           #
### ============================================================== ###

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
