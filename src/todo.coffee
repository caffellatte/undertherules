# #                                                        =======================
# #                                                        | src/telegram.coffee |
# #                                                        =======================
#
# ### ========================== ###
# { KUE_PORT }      = process.env  #
# { log }           = console      #
# ### ========================== ###
#
# ### ================================== ###
# fs       = require 'fs'                  #
# request  = require 'request'             #
# _        = require 'lodash'              #
# helpers  = require './helpers.coffee'    #
# Telegram = require 'telegram-node-bot'   #
# ### ================================== ###
#
# ### ================================ ###
# { TelegramBaseController } = Telegram  #
# ### ================================ ###
#
# ### ============================ ###
# { # Extract helpers functions      #
#   helpText,                        #
#   startText,                       #
#   aboutText,                       #
#   Formatter,                       #
#   KueJobHelper,                    #
#   DatePrettyString                 #
# }                = helpers         #
# ### ============================ ###
#
# ### ========================== ###
# kueJob = new KueJobHelper()      #
# ### ========================== ###
#
# ### ======================================================== ###
# Function::property = (prop, desc) ->               # Getter    #
#   Object.defineProperty @prototype, prop, desc     # prototype #
# ### ======================================================== ###
#
# ### ==================================================== ###
# class StartController extends TelegramBaseController       #
#   constructor: () ->                                       #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   startHandler: ($) ->                                     #
#     type    = 'start'                                      #
#     data    =                                              #
#       text: startText                                      #
#       chat: $.message.chat                                 #
#     options =                                              #
#       attempts: 5                                          #
#       priority: 'high'                                     #
#       delay: 10                                            #
#     kueJob.create type, data, options                      #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   @property 'routes',                                      #
#     get: -> 'startCommand': 'startHandler'                 #
# ### ==================================================== ###
#
# ### ==================================================== ###
# class HelpController extends TelegramBaseController        #
#   constructor: () ->                                       #
#   helpHandler: ($) ->                                      #
#     type    = 'help'                                       #
#     data    =                                              #
#       text: helpText                                       #
#       chat: $.message.chat                                 #
#     options =                                              #
#       attempts: 5                                          #
#       priority: 'high'                                     #
#       delay: 10                                            #
#     kueJob.create type, data, options                      #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   @property 'routes',                                      #
#     get: -> 'helpCommand': 'helpHandler'                   #
# ### ==================================================== ###
#
# ### =================================================================== ###
# class TrackController extends TelegramBaseController                      #
#   constructor: () ->                                                      #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   trackHandler: ($) ->                                                    #
#     {message} =  $                                                        #
#     form =                                                                #
#       link:                                                               #
#         q: 'Link for tracking:'                                           #
#         error: 'Sorry, wrong input, send only one correct link.'          #
#         validator: (message, callback) ->                                 #
#           {text, entities, chat} = message                                #
#           attachments = _.map entities, (item) ->                         #
#             {type, offset, length} = item                                 #
#             if type is 'url'                                              #
#               {url: text[offset..offset+length]}                          #
#           if attachments?[0]?.url? and attachments.length is 1            #
#             callback true, attachments                                    #
#           else                                                            #
#             callback false                                                #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#     $.runForm form, (result) ->                                           #
#       {url} = result.link[0]                                              #
#       type    = 'track'                                                   #
#       data    =                                                           #
#         text: url                                                         #
#         chat: $.message.chat                                              #
#       options =                                                           #
#         attempts: 5                                                       #
#         priority: 'high'                                                  #
#         delay: 10                                                         #
#       kueJob.create type, data, options                                   #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   @property 'routes',                                                     #
#     get: -> 'trackCommand': 'trackHandler'                                #
# ### =================================================================== ###
#
# ### ======================================================== ###
# class FindController extends TelegramBaseController            #
#   constructor: () ->                                           #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   findHandler: ($) ->                                          #
#     type    = 'find'                                           #
#     data    =                                                  #
#       text: 'Error! Try /find later.'                          #
#       chat: $.message.chat                                     #
#     options =                                                  #
#       attempts: 5                                              #
#       priority: 'high'                                         #
#       delay: 10                                                #
#     kueJob.create type, data, options                          #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   @property 'routes',                                          #
#     get: -> 'findCommand': 'findHandler'                       #
# ### ======================================================== ###
#
# ### ======================================================== ###
# class ListController extends TelegramBaseController            #
#   constructor: () ->                                           #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   listHandler: ($) ->                                          #
#     type    = 'list'                                           #
#     data    =                                                  #
#       text: 'Error! Try /list later.'                          #
#       chat: $.message.chat                                     #
#     options =                                                  #
#       attempts: 5                                              #
#       priority: 'high'                                         #
#       delay: 10                                                #
#     kueJob.create type, data, options                          #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   @property 'routes',                                          #
#     get: -> 'listCommand': 'listHandler'                       #
# ### ======================================================== ###
#
# ### ======================================================== ###
# class AboutController extends TelegramBaseController           #
#   constructor: () ->                                           #
#   aboutHandler: ($) ->                                         #
#     type    = 'about'                                          #
#     data    =                                                  #
#       text: aboutText                                          #
#       chat: $.message.chat                                     #
#     options =                                                  #
#       attempts: 5                                              #
#       priority: 'high'                                         #
#       delay: 10                                                #
#     kueJob.create type, data, options                          #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   @property 'routes',                                          #
#     get: -> 'aboutCommand': 'aboutHandler'                     #
# ### ======================================================== ###
#
# ### ======================================================== ###
# class ConfigController extends TelegramBaseController          #
#   constructor: () ->                                           #
#   configHandler: ($) ->                                        #
#     type    = 'config'                                         #
#     data    =                                                  #
#       text: 'Error! Try /config later.'                        #
#       chat: $.message.chat                                     #
#     options =                                                  #
#       attempts: 5                                              #
#       priority: 'high'                                         #
#       delay: 10                                                #
#     kueJob.create type, data, options                          #
# # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#   @property 'routes',                                          #
#     get: -> 'configCommand': 'configHandler'                   #
# ### ======================================================== ###
#
#
# ### ======================================================== ###
# class OtherwiseController extends TelegramBaseController       #
#   constructor: () ->                                           #
#   handle: ($) ->                                               #
#     $.sendMessage 'Unknown commands. Try /help.'               #
#     return                                                     #
# ### ======================================================== ###
#
# ### ============================================================ ###
# # Node.js, Require and Exports                                     #
# module.exports.StartController     = StartController               #
# module.exports.HelpController      = HelpController                #
# module.exports.TrackController     = TrackController               #
# module.exports.FindController      = FindController                #
# module.exports.ListController      = ListController                #
# module.exports.AboutController     = AboutController               #
# module.exports.ConfigController    = ConfigController              #
# module.exports.OtherwiseController = OtherwiseController           #
# ### ============================================================ ###

#     ===================================================================
#     | Copyright (c) 2016 Mikhail G. Lutsenko (m.g.lutsenko@gmail.com) |
#     |          https://github.com/caffellatte/undertherules           |
#     ===================================================================

#
# kue.Job.rangeByState 'complete', 0, 1000, 'asc', (err, jobs) ->  #
#   jobs.forEach (job) ->                                          #
#     job.remove ->                                                #
#       console.log 'removed ', job.id                             #
#       return                                                     #
#     return                                                       #
#   return                                                         #

### ======================================================================== ###
# trackInstagramMediaHandler = (data, done) ->
#   {chatId, mediaId} = data
#   if !chatId? or !mediaId?               # create new user  #
#     errorText = """
#     Error! [kue.coffee](trackInstagramMediaHandler).
#     Faild to track for #{chatId}.
#     """                                                                        #
#     log errorText                                                              #
#     return done(new Error(errorText))                                          #
#   uri = "https://www.instagram.com/p/#{mediaId}?__a=1"
#   request uri, (error, response, body) ->
#     if !error and response.statusCode is 200
#       try
#         data = JSON.parse body
#       catch error
#         log error
#         return done(new Error(error))
#       finally
#         {media} = data
#         {video_views, date, likes, comments} = media
#         log likes: "#{likes.count}"
#         # LOoooP! ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#         requestTrackInstagramMedia =
#           url: "http://localhost:#{KUE_PORT}/job"
#           headers: 'Content-Type': 'application/json'
#           method:  'POST'                                  #
#           title:   "[Track Loop] to (#{mediaId})"
#           mediaId:  mediaId
#           chatId:   chatId
#         job = queue.create('trackInstagramMediaHandler', requestTrackInstagramMedia).removeOnComplete( true ).save((err) ->      #
#           if !err                                                                    #
#             log "[kue.coffee] {trackHandler} (OK) Kue job id: #{job.id}"                            #
#           return                                                                     #
#         ).delay(1000*60*1)
#         # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
#         done()
#         return
#     else
#       return done(new Error(error))
### ====================================================================== ###

### ======================================================================== ###
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
# newUser = (data, done) ->                       # Telegram New  User #
#   {chat} = data.userData                                                      #
#   {id, type, username, first_name, last_name} = chat
#   chat.track = []
#   chat.find  = []
#   db = multilevel.client()
#   con = net.connect LEVEL_PORT
#   con.pipe(db.createRpcStream()).pipe con
#   db.get id, (err, val) ->
#     if err
#       db.put id, chat, (err) ->
#       if err
#         return done(new Error(err))
#         throw err
#       done()
#       return
#     db.close()
#     done()                                                                     #
#     return                                                                     #
### ====================================================================== ###

### ======================================================================== ###
# createSaveJob = (type, job) -> # Create Save Kue Job
#   {data, log} = job
#   {hashtag, nodes} = data
#   requestData =
#     url: "http://localhost:#{KUE_PORT}/job"
#     headers: 'Content-Type': 'application/json'
#     method: 'POST'
#     json:
#       type: type
#       data:
#         title: "Save nodes for #{hashtag}"
#         hashtag: hashtag
#         nodes: nodes
#       options:
#         attempts: 5
#         priority: 'high'
#         delay: 23
#   request requestData, (error, response, body) ->
#     if error then log error else log JSON.stringify body
#     return
### ======================================================================== ###
# search = (job, done) -> # Search Job
#   {data, log} = job
#   {hashtag, end_cursor} = data
#   hashtagEncoded = encodeURIComponent hashtag
#   uri = "https://www.instagram.com/explore/tags/#{hashtagEncoded}/?__a=1"
#   if end_cursor then uri += "&max_id=#{end_cursor}"
#   request uri, (error, response, body) =>
#     if !error and response.statusCode == 200
#       try
#         {tag} = JSON.parse body
#       catch error
#         return done new Error(error)
#       {media, name, content_advisory, top_posts} = tag
#       {count, page_info, nodes} = media
#       {has_previous_page, start_cursor, end_cursor, has_next_page} = page_info
#       tagSearchResult  = "About #{count} results for ##{name}. Nodes: "
#       tagSearchResult += "#{nodes.length} Has_Next_Page: #{has_next_page}"
#       log tagSearchResult
#       createSaveJob 'save', {data:{hashtag: name, nodes: nodes},log:log}
#       if has_next_page
#         createSearchJob 'search',
#           {data:{hashtag: name, end_cursor: end_cursor},log:log}
#         done()
#     else
#       log error
#       return done new Error(error)
### ======================================================================== ###
### ====================================================================== ###
# module.exports.VK = () ->
# require './callVkApi.js'
#
# # vkLinkParser.coffee
# vkLinkParser = (video) ->
#     if '?' in path
#         id = path.split('/')[1].split('?')[0].replace('video','')
#         {z} = querystring.parse query
#         id = z.split('/')[0].replace('video','')
#     else
#         id = path.split('/')[1].replace('video','')
#     _id = id
#   next links
# global.vkVideoGet = (next, retry, video) ->
#   {hostname, href, path, query} = link
#   # console.log video
#   {id, href, hostname} = video
#   callVkApi 'video.get',
#     videos:         id
#     # offset:         offset
#     # count:          loadPerPart
#     extended:       1
#     access_token: '9e050d8ecb1ccae91faf5dc035b1eddd5f247ac311851a5e68d4e26c00b7c06b88e4a95300b1282030768' # 'e7ddcbe871c91ccbc993d60047e945cf093b2ed0c62ccd377cdc8a82cb4c3bada24057544073984df731f'
#   , null, (vkResp) ->
#     # console.log JSON.stringify vkResp, null, 2
#     {items} = vkResp
#     {date, views, comments, likes, repeat} = items[0]
#     Time = date
#     stats =
#       views_count: views
#       updated: +new Date()//1000
#       likes_count: likes.count
#       comments_count: comments
#       # repeat: repeat
#     # console.log {link: href, created: Time, stats: stats, source: hostname}
#     # process.exit 0
#     next {link: href, created: Time, stats: stats, source: hostname}
# module.exports.OK = () ->
# querystring = require 'querystring'
# _           = require 'lodash'
# fs          = require 'fs-extra'
# request     = require 'request'
# crypto      = require 'crypto'
# path        = require 'path'
# authDir     = path.join __dirname, 'auth'
# md5 = (text) -> crypto.createHash('md5').update(text).digest("hex")
# # ok_api_config   = JSON.parse fs.readFileSync "#{authDir}/config.json", encoding: 'utf-8'
# # {clientSecret, applicationKey, access_token}  = ok_api_config
# #
# module.exports.callOkApi = (params, access, cb, errCounter=0) ->
#   console.log params, access, cb, errCounter
# #   # console.log "ok call API: method - #{params.method}"
# #
# #   params.application_key = applicationKey
# #   params.application_secret_key = clientSecret
# #   params.format='json'
# #
# #   paramsList = []
# #   for param, val of params
# #     setVal = val
# #     if typeof val == "object"
# #       val = JSON.stringify(val)
# #       params[param] = val
# #
# #     paramsList.push param + '=' + val
# #
# #   paramsList.sort (a, b) ->
# #     if a > b then return 1
# #     if a < b then return -1
# #     return 0
# #
# #   # console.log 'paramsList:', paramsList
# #   paramString = ""
# #   paramString += param for param in paramsList
# #
# #   tokenMD5 = md5(access_token + clientSecret)
# #   resultString = md5(paramString + tokenMD5)
# #
# #   resultString = resultString.toLowerCase()
# #
# #   requestString = 'https://api.ok.ru/fb.do?'
# #
# #   paramString = ""
# #   paramString += param + '=' + encodeURIComponent(val) + '&' for param, val of params
# #
# #   paramString += 'access_token=' + access_token
# #   paramString += '&sig=' + resultString
# #
# #   requestString = requestString + paramString
# #   # console.log requestString
# #   # process.exit 0
# #   request.get requestString, (err, req, body) =>
# #     result = JSON.parse body
# #     if err?
# #       # console.log JSON.stringify err, null, 2
# #       cb? false, params, access_token
# #     else
# #       # console.log JSON.stringify body, null, 2
# #       cb? result, params, access_token

# path = require 'path'
# require path.join __dirname, 'callOkApi'
# request = require 'request'
# fs = require 'fs-extra'
# url = require 'url'
# configOkApi = path.join __dirname, 'auth', 'config.json'
# ok_api_config   = JSON.parse fs.readFileSync configOkApi, encoding: 'utf-8'
# {applicationKey, access_token}  = ok_api_config
#
# # okLinkParser.coffee
# okLinkParser = (video) ->
#   id = path.split('/')[2]
#   _id = id
#   next links
#
# global.okVideoGet = (next, retry, link) ->
#     {hostname, href, path, query} = link
#     {id, href, hostname} = video
#     method = 'discussions.get'
#     params =
#         application_key: applicationKey
#         method: method
#         discussionId: id
#         discussionType: 'GROUP_MOVIE'
#         fields: 'video.*,discussion.*'
#     # result = []
#     callOkApi params, access_token, (body, params, access_token) =>
#         # console.log JSON.stringify body, null, 2
#         if body?.discussion? and body?.entities?
#             {discussion, entities} = body
#             videos = entities.videos[0]
#             Time = videos.created_ms // 1000
#             stats =
#                 views_count: videos.total_views
#                 likes_count:  videos.likes_count
#                 daily_views_count: videos.daily_views
#                 discussion:
#                     comments_count: discussion.total_comments_count
#                     likes_count: discussion.like_count
#                 updated: +new Date()//1000
#             # console.log {link: href, created: Time, stats: stats, source: hostname}
#             next {link: href, created: Time, stats: stats, source: hostname}
#         else
#             next true
# module.exports.YT = () ->
  # # Modules
  # path    = require 'path'
  # YouTube = require 'callYtApi.coffee'
  # insert  = require 'insert.coffee'
  # qstring = require 'querystring'
  # # Token
  # {YOUTUBE_TOKEN} = process.env
  # youTube.setKey YOUTUBE_TOKEN
  # # Initilization
  # youTube = new YouTube
  # # Exports @function LinkParser
  # module.exports.LinkParser = (video, next) ->
  #   # Checking URL link (YouTube)
  #   if query
  #     id = _.map(qstring.parse(query), (item) -> return item)[0]
  #     _id = id
  #   else
  #     if path.split('/')[1] is 'user'
  #       videos = []
  #       cb = (channelId, nextPageToken) =>
  #         youTube.getPlayListsByChannelId channelId, nextPageToken, (error, result) =>
  #           if error
  #             console.log error
  #           else
  #             videos.push result.items...
  #           if result.nextPageToken?
  #             console.log result.nextPageToken
  #             cb channelId, result.nextPageToken
  #           else
  #             for link in videos
  #               scraperInsertStats next, null, link
  #         cb path.split('/')[2]
  #     else
  #       id = _id = path[1..]
  #       process.exit 0
  #     # console.log 'youtube', id, _id
  #   # next links
  # # Exports @function LinkParser
  # module.exports.GetVideo = (next, retry, video) ->
  #   {hostname, href, path, query} = link
  #   # console.log video
  #   {id, _id, href, hostname} = video
  #   # console.log video
  #   youTube.getById id, (error, result) =>
  #     if result.items[0]?.statistics?
  #       {statistics, snippet} = result.items[0]
  #       Time = (new Date(snippet.publishedAt).getTime()//1000)
  #       stats =
  #         views_count: statistics.viewCount
  #         likes_count:  statistics.likeCount
  #         dislikes_count: statistics.dislikeCount
  #         favorite_count: statistics.favoriteCount
  #         comment_count: statistics.commentCount
  #         updated: +new Date()//1000
  #       next {link: href, created: Time, stats: stats, source: hostname}
  #     else
  #       next true
# module.exports.IG = () ->
#
#
# igVideoGet process.argv[1]
# module.exports.FB = () ->
# DOMParser      = require 'xmldom' # Manipulting DOM-tree
# xpath          = require 'xpath'  # find by xpath
# url            = require 'url'    # url parsing
# {log}          = require 'util'   # logging
# {exec}         = require 'child_process'   # exit for debugging
# # ************************************************ #
# module.exports = fbVideoGet: (link, next) ->
#   # for DOMParser
#   parserOptions =
#     locator: {}
#     errorHandler:
#       warning: (w) ->
#         console.warn w
#         return
#     error: @warning
#     fatalError: @warning
#   # - - - - - - - - - - -
#   # pre-Parse raw link by 'url' module
#   {hostname, path, query, href} = url.parse link
#   # Get unique ID
#   id = path.split('/')[3]
#   # Create URI for curl
#   uri = "https://www.facebook.com/video/channel/view/details/async/#{path.split('/')[3]}/?&__a=1"
#   console.log href, '->', uri
#   exec "bash #{__dirname}/fbCurl.sh '#{uri}'", (error, stdout, stderr) ->
#     # Clean up response header
#     body =  stdout.replace 'for (;;);', ''
#     # Get JSON Objet from String (response)
#     try
#       data = JSON.parse body
#       # console.log data
#     catch error
#       # If error
#       console.log error
#       next false
#     finally
#       # Extract data using DOM-tree
#       if !data?.domops?
#         next false
#       else
#         {domops} = data
#         {__html} = domops[0][3]
#         xml = new DOMParser(parserOptions).parseFromString(__html,'text/xml')
#         Time = parseInt(xpath.select('//form//div/div[1]/div[1]/div/div/div/div[2]/a/abbr/@data-utime', xml).toString().replace(/[^0-9.]/g, ''))
#         stats =
#           views_count: parseInt(xpath.select('//form/div/div[2]/span/text()', xml).toString().replace(/[^0-9.]/g, ''))
#           updated: +new Date()//1000
#         # console.log {link: href, created: Time, stats: stats, source: hostname}
#         next {link: href, created: Time, stats: stats, source: hostname}
# module.exports.MM = () ->
# url     = require 'url'
# request = require 'request'
# mmVideoGet = (link) ->
#   {hostname, href, path, query} = url.parse link
#   id = path.split('/')[5].replace('.html', '')
#   uri =  "http://my.mail.ru/cgi-bin/my/ajax?user=#{path.split('/')[2]}&xemail=&ajax_call=1&func_name=video.get_list&mna=&mnb=&arg_type=user&arg_all=1"
#
#   loadPerPart = 50
#   results = []
#   loaded = 0
#   offset = 0
#   _limit = "&arg_limit=#{loadPerPart}"
#   getPart = (offset, _id, cb) ->
#
#     request "#{id}&arg_offset=#{offset}&arg_limit=50", (error, response, body) ->
#       if !error and response.statusCode is 200
#         items = JSON.parse(body)[2]
#         for item in items.items
#           if item.id.toString() is _id.toString()
#             {UrlHtml,PreviewCount,ViewCount,Time} = item
#             stats =
#               previews_count: PreviewCount
#               views_count: ViewCount
#               updated: +new Date()//1000
#             results.push {link: UrlHtml, created: parseInt(Time), stats: stats, source: hostname}
#         if loaded < items.total
#           getPart offset + loadPerPart, _id, cb
#         else
#           cb results
#       else
#         next true
#     loaded += loadPerPart
#
#   getPart 0, _id, next
#
# mmVideoGet process.argv[1]
#!/bin/bash

# If it redirects to http://www.facebook.com/login.php at the end, wait a few minutes and try again
#
# EMAIL='*' # edit this
# PASS='*' # edit this
#
# COOKIES='/tmp/cookies.txt'
# USER_AGENT='Firefox/3.5'
#
# MKFIFO_NAME="dump"
#
# URL=$1
#
# function fifo_ctrl() {
#   rm -f $MKFIFO_NAME
#   mkfifo $MKFIFO_NAME
# }
#
# function login {
#   curl -X GET 'https://www.facebook.com/home.php' --verbose --user-agent $USER_AGENT --cookie $COOKIES --cookie-jar $COOKIES --location
#   curl -X POST 'https://login.facebook.com/login.php' --verbose --user-agent $USER_AGENT --data-urlencode "email=${EMAIL}" --data-urlencode "pass=${PASS}" --cookie $COOKIES --cookie-jar $COOKIES
# }
#
# function get {
#   # echo $(cat $COOKIES)
#   # echo -e "\n\n"
#   curl -X GET "$URL"  --user-agent $USER_AGENT --cookie $COOKIES --cookie-jar $COOKIES
#   # --verbose --output $MKFIFO_NAME
#   # echo -e "\n\n"
# }
#
# if [ ! -f $COOKIES ]; then
#   login
# else
#   # echo -e "\n\n"
#   # echo "Retrive URL: [$URL]"
#   # echo -e "\n\n"
#   get
# fi
#
