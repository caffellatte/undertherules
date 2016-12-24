# main.coffee.md

## Import NPM modules

    shoe     = require 'shoe'
    dnode    = require 'dnode'
    domready = require 'domready'

## Wait for DOM tree

    domready ->

      result = document.getElementById('chat')
      stream = shoe('/dnode')
      d = dnode()
      d.on 'remote', (remote) ->
        remote.echo 'beep', (s) ->
          result.textContent = 'beep => ' + s
      d.pipe(stream).pipe d
