# dnode.coffee.md

## Import NPM modules

    http       = require('http')
    shoe       = require('shoe')
    dnode      = require('dnode')

## Extract functions & constans from modules

    {DNODE_PORT, STATIC_PATH} = process.env
    {log}                     = console

## A simple static file server middleware. Using it with a raw http server

    ecstatic = require('ecstatic')(STATIC_PATH)

## Create HTTP static server

    server = http.createServer(ecstatic)

## Define API object providing integration vith dnode

    API = {
      dateTime: (s, cb) ->
        # currentDateTime = DatePrettyString(s)
        cb(currentDateTime)
      search: (s, cb) ->
        log(s)
        cb(s)
    }

## Start Dnode

    server.listen DNODE_PORT, ->
      log("""
      RPC module (dnode) successful started. Listen port: #{DNODE_PORT}.
      Web: http://0.0.0.0:#{DNODE_PORT}
      """)

## Use dnode via shoe & Install endpoint

    sock = shoe((stream) ->
      d = dnode(API)
      d.pipe(stream).pipe(d)
    )
    sock.install(server, '/dnode')
