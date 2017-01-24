# networs.com
Simple collection of libraries for authorization, data scraping & etc.


## Import NPM modules

    url     = require 'url'
    kue     = require 'kue'
    http    = require 'http'
    request = require 'request'

## Extract functions & constans from modules

    {log} = console

## Environment virables

    {VK_CLIENT_ID}     = process.env
    {VK_CLIENT_SECRET} = process.env
    {VK_REDIRECT_HOST} = process.env
    {VK_REDIRECT_PORT} = process.env
    VK_REDIRECT_PORT = 8877 # process.env

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

## using array for storing reserved keywords for mix-ins.

    moduleKeywords = ['extended', 'included']

## Declare Module that using mix-ins

    class Module

### **Extending**

      @extend: (obj) ->
        for key, value of obj when key not in moduleKeywords
          @[key] = value

        obj.extended?.apply(@)
        this

### **Including**

      @include: (obj) ->
        for key, value of obj when key not in moduleKeywords
          @::[key] = value

        obj.included?.apply(@)
        this

## Defi

    ORM =
      find: (id) ->
        log id
      create: (attrs) ->
      extended: ->
        @include
          save: ->

    class User extends Module
      @extend ORM

## Start

    user = User.find(1)

    handler = (req, res) ->
      parts = url.parse(req.url, true)
      {code, state} = parts.query
      if code and state
        switch state
          when 'vk'
            vkUrl  = 'https://oauth.vk.com/access_token?'
            vkUrl += "client_id=#{VK_CLIENT_ID}&client_secret=#{VK_CLIENT_SECRET}&"
            vkUrl += "redirect_uri=http://#{VK_REDIRECT_HOST}:#{VK_REDIRECT_PORT}/&"
            vkUrl +=  "code=#{code}"
            request vkUrl, (error, response, body) ->
              if !error and response.statusCode == 200
                console.log body
                res.end(body)
          else
            res.end('Error!')
      else
        {error, error_description} = parts.query
        res.end("#{error}. #{error_description}")

    server = http.createServer handler

    server.listen VK_REDIRECT_PORT, ->
      log("""
      Netwoks module successful started. Listen port: #{VK_REDIRECT_PORT}.
      Web: http://0.0.0.0:#{VK_REDIRECT_PORT}
      """)
    # user = new User
    # user.save()
