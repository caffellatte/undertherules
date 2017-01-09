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

# vkVideoGet.coffee
require './callVkApi.js'
global.vkVideoGet = (next, retry, video) ->
    # console.log video
    {id, href, hostname} = video
    callVkApi 'video.get',
            videos:         id
            # offset:         offset
            # count:          loadPerPart
            extended:       1
            access_token: '9e050d8ecb1ccae91faf5dc035b1eddd5f247ac311851a5e68d4e26c00b7c06b88e4a95300b1282030768' # 'e7ddcbe871c91ccbc993d60047e945cf093b2ed0c62ccd377cdc8a82cb4c3bada24057544073984df731f'
        , null, (vkResp) ->
            # console.log JSON.stringify vkResp, null, 2
            {items} = vkResp
            {date, views, comments, likes, repeat} = items[0]
            Time = date
            stats =
                views_count: views
                updated: +new Date()//1000
                likes_count: likes.count
                comments_count: comments
                # repeat: repeat
            # console.log {link: href, created: Time, stats: stats, source: hostname}
            # process.exit 0
            next {link: href, created: Time, stats: stats, source: hostname}
    # {id} = video
    # loadPerPart = global.loadPerPart
    # results = []
    # loaded = 0
    # getPart = (offset, cb) ->
    #     callVkApi 'video.get',
    #         videos:         'id'
    #         offset:         offset
    #         count:          loadPerPart
    #         extended:       1
    #         access_token: global.vk_access_token
    #     , null, (vkResp) ->
    #
    #         for item in vkResp.items
    #             results.push item
    #         if loaded < vkResp.count and offset / results.length < 3
    #             getPart offset + loadPerPart, cb
    #         else
    #             cb results
    #         console.log 'video get:', results.length
    #
    #     loaded += loadPerPart
    #
    # getPart 0, next



request = require 'request'
querystring = require 'querystring'
timestamp = 0

    global.callVkApi = (method, params, token, cb) -> #, retry = 5) ->
      url = 'https://api.vk.com' + '/method/' + method
      url += '?access_token=' + token if token
      params.v = '5.45'
      timespread = (Math.floor +new Date() / 1000) - timestamp
      if timespread < 0.334 then global.delay += global.delayOffset
      else global.delay = 50
      # console.log 'Global Delay:', global.delay, 'Time Spread:', timespread
      setTimeout ->

          vkRespCallback = (err, res, body) ->

              try
                  o = JSON.parse body
              catch e
                  console.log e, err
                  console.log 'request not successed', e, url, body
                  o = {}
                  setTimeout ->
                      request.post url, {form:params,timeout:15000}, vkRespCallback
                  , 1000

              console.log o.error if o.error

              errorCode = o.error?.error_code || null

              if errorCode?
                  switch errorCode
                      when 801
                          # Closed
                          console.log '801'
                          cb? {count: 0, items: []}
                      when 6
                          setTimeout ->
                              request.post url, {form:params,timeout:15000}, vkRespCallback
                          , 1000
                          return
                      when 15
                          console.log '15'
                          cb? {count: 0, items: []}

              if o.response
                  # console.log 'Recive data from API!', params, "length: #{o.response.toString().length} Byte"
                  cb? o.response
          # console.log url, params
          # process.exit 0
          request.post url, {form:params,timeout:15000}, vkRespCallback

      , global.delay
      timestamp = Math.floor +new Date() / 1000


    class VKontakte
    API_URL="http://api.vk.com/method/"
    require './callVkApi.js'

    # vkLinkParser.coffee
    vkLinkParser = (video) ->
        if '?' in path
            id = path.split('/')[1].split('?')[0].replace('video','')
            {z} = querystring.parse query
            id = z.split('/')[0].replace('video','')
        else
            id = path.split('/')[1].replace('video','')
        _id = id
      next links
    global.vkVideoGet = (next, retry, video) ->
      {hostname, href, path, query} = link
      # console.log video
      {id, href, hostname} = video
      callVkApi 'video.get',
        videos:         id
        # offset:         offset
        # count:          loadPerPart
        extended:       1
        access_token: '9e050d8ecb1ccae91faf5dc035b1eddd5f247ac311851a5e68d4e26c00b7c06b88e4a95300b1282030768' # 'e7ddcbe871c91ccbc993d60047e945cf093b2ed0c62ccd377cdc8a82cb4c3bada24057544073984df731f'
      , null, (vkResp) ->
        # console.log JSON.stringify vkResp, null, 2
        {items} = vkResp
        {date, views, comments, likes, repeat} = items[0]
        Time = date
        stats =
          views_count: views
          updated: +new Date()//1000
          likes_count: likes.count
          comments_count: comments
          # repeat: repeat
        # console.log {link: href, created: Time, stats: stats, source: hostname}
        # process.exit 0
        next {link: href, created: Time, stats: stats, source: hostname}
