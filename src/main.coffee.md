Module provides **nimble** web-data operations.

Extract environment varibles

    {STATIC_PATH} = process.env

Import modules

    kue         = require 'kue'
    http        = require 'http'
    sockjs      = require 'sockjs'
    node_static = require 'node-static'

Echo sockjs server (1)

    sockjs_opts = sockjs_url: 'http://cdn.jsdelivr.net/sockjs/1.0.1/sockjs.min.js'
    sockjs_echo = sockjs.createServer(sockjs_opts)
    sockjs_echo.on 'connection', (conn) ->
      conn.on 'data', (message) ->
        conn.write message
        return
      return

Static files server (2)

    static_directory = new (node_static.Server)(STATIC_PATH)

Usual http stuff (3)

    server = http.createServer()
    server.addListener 'request', (req, res) ->
      static_directory.serve req, res
      return
    server.addListener 'upgrade', (req, res) ->
      res.end()
      return
    sockjs_echo.installHandlers server, prefix: '/echo'
    console.log ' [*] Listening on 0.0.0.0:9999'
    server.listen 9999, '0.0.0.0'

Kue is a priority job queue backed by redis, built for node.js

    kue.app.listen 3000, ->
    console.log '[OK] Kue listening on 0.0.0.0:3000'


The title defaults to "Kue", to alter this invoke:

    kue.app.set 'title', 'UnderTheRules'

Repository: https://github.com/caffellatte/undertherules
