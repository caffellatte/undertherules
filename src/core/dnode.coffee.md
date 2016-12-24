dnode.coffee
============

dnode.coffee uses the streaming interface provided by shoe,which is just
a thin wrapper on top of sockjs that provides websockets with fallbacks.

## Import NPM modules

    http = require('http')
    shoe = require('shoe')
    dnode = require('dnode')

## Import environment parameters

    { STATIC_PATH } = process.env

## Extract helpful Functions

    { log } = console

## A simple static file server middleware. Using it with a raw http server

    ecstatic = require('ecstatic')(STATIC_PATH)

## Create HTTP server & start listening on 9999 port

    server = http.createServer(ecstatic)
    server.listen 9999

## Use dnode via shoe

    sock = shoe((stream) ->
      d = dnode(transform: (s, cb) ->
        res = s.replace(/[aeiou]{2,}/, 'oo').toUpperCase()
        cb res
        return
      )
      d.pipe(stream).pipe d
      return
    )

## Install endpoint

    sock.install server, '/dnode'
