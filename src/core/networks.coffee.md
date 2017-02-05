# networs.com
Simple collection of libraries for authorization, data scraping & etc.


## Import NPM modules

    fs          = require 'fs-extra'
    url         = require 'url'
    kue         = require 'kue'
    http        = require 'http'
    natural     = require 'natural'
    request     = require 'request'
    querystring = require 'querystring'

## Extract functions & constans from modules

    {log} = console

## Environment virables

    {VK_CLIENT_ID}     = process.env
    {VK_CLIENT_SECRET} = process.env
    {VK_REDIRECT_HOST} = process.env
    {VK_REDIRECT_PORT} = process.env
    {VK_REDIRECT_PORT} = process.env
    {VK_VERSION}       = process.env
    {STATIC_DIR}       = process.env
    {PANEL_PORT}       = process.env
    {PANEL_HOST}       = process.env

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

## Define link tokenizer

    tokenizer = new natural.RegexpTokenizer({pattern: /(https?:\/\/[^\s]+)/g})

    queue.process 'vkWallStatic', (job, done) ->
      {chatId, name, items} = job.data
      filename = "#{STATIC_DIR}/files/#{name}-wall-#{items.length}.csv"
      fs.writeFileSync filename, "id;from_id;owner_id;date;post_type;comments;likes;reposts\n"
      [first, ..., last] = items
      rows = ''
      for item in items
        {id,from_id,owner_id,date,post_type,comments,likes,reposts} = item
        rows += "#{id};#{from_id};#{owner_id};#{new Date(date*1000)};#{post_type};#{comments.count};#{likes.count};#{reposts.count}\n"
        if id is last.id
          fs.appendFileSync filename, rows
          done(null, "http://#{PANEL_HOST}:#{PANEL_PORT}/files/#{name}-wall-#{items.length}.csv")

    queue.process 'vkMediaScraper', (job, done) ->
      {chatId, method, params, items} = job.data
      requestUrl = "https://api.vk.com/method/#{method}?#{querystring.stringify(params)}"
      request requestUrl, (error, response, body) =>
        if not error and response.statusCode is 200
          body = JSON.parse(body)
          if (body.response.count - params.offset) > 0
            params.offset += 100
            items = items.concat(body.response.items)
            vkMediaScraperJob = queue.create('vkMediaScraper',
              title: "mediaScraper Telegram UID: #{chatId}.",
              chatId: chatId,
              method: 'wall.get',
              params: params,
              items: items).save()
          else
            vkWallStaticJob = queue.create('vkWallStatic',
              title: "vkWallStatic Telegram UID: #{chatId}.",
              chatId: chatId,
              name: (params.domain || params.user_id),
              items: items).save()
            vkWallStaticJob.on 'complete', (result) =>
              queue.create('sendMessage',
                title: "vkWallStaticJob Telegram UID: #{chatId}.",
                chatId: chatId,
                text: result).save()
          done()
        else
          done(error)
      done()

    queue.process 'mediaAnalyzer', (job, done) ->
      {chatId, href, host, path} = job.data
      GetTokensJob = queue.create('GetTokens',
        title: 'Get Tokens',
        chatId: chatId).save()
      GetTokensJob.on 'complete', (result) ->
        {access_token} = result[0]
        if access_token
          params =
            access_token: access_token
            offset: 0
            count: 100
            extended: 0
            filter: 'all'
            v: VK_VERSION
          if 'id' in path
            params.owner_id = path[3..path.length]
          else
            params.domain = path[1..path.length]
          vkMediaScraperJob = queue.create('vkMediaScraper',
            title: "mediaScraper Telegram UID: #{chatId}.",
            chatId: chatId,
            method: 'wall.get',
            params: params,
            items: []).save()
      done()

    queue.process 'mediaChecker', (job, done) ->
      {chatId, text} = job.data
      rawLinks = tokenizer.tokenize(text)
      if rawLinks.length < 1
        queue.create('sendMessage',
          title: "mediaChecker Telegram UID: #{chatId}."
          chatId: chatId
          text: 'Unknown command. List of commands: /help.').save()

      rawLinks.forEach (item) ->
        {href, host, path} = url.parse(item)
        switch host
          when 'vk.com'
            if path
              queue.create('mediaAnalyzer',
                title: "Analyze Media #{href}",
                chatId: chatId,
                href: href,
                host: host,
                path: path).save()
        done()


## HTTP handler

    handler = (req, res) ->
      parts = url.parse(req.url, true)
      {code, state} = parts.query
      if code and state
        [first, ..., last] = state.split(',')
        switch first
          when 'vk'
            chatId = last
            console.log(chatId)
            vkUrl  = 'https://oauth.vk.com/access_token?'
            vkUrl += "client_id=#{VK_CLIENT_ID}&client_secret=#{VK_CLIENT_SECRET}&"
            vkUrl += "redirect_uri=http://#{VK_REDIRECT_HOST}:#{VK_REDIRECT_PORT}/&"
            vkUrl +=  "code=#{code}"
            request vkUrl, (error, response, body) ->
              if !error and response.statusCode == 200
                console.log body
                {access_token, expires_in,user_id,email} = JSON.parse(body)
                queue.create('SaveTokens',
                  title: "Send support text. Telegram UID: #{chatId}."
                  chatId: chatId,
                  access_token: access_token,
                  expires_in: expires_in,
                  user_id: user_id,
                  email: email
                  first: first).save()
                # Seve to db
                # res.end(body)
                res.writeHead(302, {'Location': 'http://t.me/UnderTheRulesBot'})
                res.end()
          else
            res.end(error)
      else
        {error, error_description} = parts.query
        res.end("#{error}. #{error_description}")

    server = http.createServer handler

    server.listen VK_REDIRECT_PORT, ->
      log("""
      Netwoks module successful started. Listen port: #{VK_REDIRECT_PORT}.
      Web: http://0.0.0.0:#{VK_REDIRECT_PORT}
      """)

## **Clean** static folder on exit

    exitHandler = (options, err) =>
      if err
        log err.stack
      if options.exit
        process.exit()
        return
      if options.cleanup
        log 'cleanup'

### **do something when app is closing**

    process.on 'exit', exitHandler.bind(null, cleanup: true)

### **catches ctrl+c event**

    process.on 'SIGINT', exitHandler.bind(null, exit: true)

### **catches uncaught exceptions**

    process.on 'uncaughtException', exitHandler.bind(null, exit: true)
