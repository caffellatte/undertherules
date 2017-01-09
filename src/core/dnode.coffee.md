# dnode.coffee.md

## Import NPM modules

    http       = require('http')
    shoe       = require('shoe')
    dnode      = require('dnode')
    helpers    = require('./helpers.coffee.md')

## Extract functions & constans from modules

    {DnodeCrypto} = helpers
    {DNODE_PORT, STATIC_PATH, LEVEL_DNODE_PORT} = process.env
    {log}                     = console

## A simple static file server middleware. Using it with a raw http server

    ecstatic = require('ecstatic')(STATIC_PATH)

## Create HTTP static server

    server = http.createServer(ecstatic)

## Define API object providing integration vith dnode

    API =
      dateTime: (s, cb) ->
        # currentDateTime = DatePrettyString(s)
        cb(currentDateTime)
      search: (s, cb) ->
        log(s)
        cb(s)
      auth: (_user, _pass, cb) ->
        if typeof cb != 'function'
          return
        ld = dnode.connect(LEVEL_DNODE_PORT)
        ld.on 'remote', (remote) ->
          id = _user / (+new Date() // (1000 * 60 * 60 * 24))
          remote.panel id, (s) ->
            {subject, object} = s
            ld.end()
            {user, pass} = DnodeCrypto subject, object
            if +_user is +user and _pass is pass
              console.log 'signed in: ' + subject
              cb null, subject
            else
              cb 'ACCESS DENIED'
            return

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
