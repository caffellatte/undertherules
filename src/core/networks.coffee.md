# networs.com
Simple collection of libraries for authorization, data scraping & etc.


## Import NPM modules

    http = require 'http'

## Extract functions & constans from modules

    {log} = console

## Environment virables

    VK_REDIRECT_PORT = 8877 # process.env

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
      res.end('ok')

    server = http.createServer handler

    server.listen VK_REDIRECT_PORT, ->
      log("""
      Netwoks module successful started. Listen port: #{VK_REDIRECT_PORT}.
      Web: http://0.0.0.0:#{VK_REDIRECT_PORT}
      """)
    # user = new User
    # user.save()
