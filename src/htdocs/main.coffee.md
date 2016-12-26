# main.coffee.md

## *Import NPM modules*

    shoe     = require 'shoe'
    dnode    = require 'dnode'
    domready = require 'domready'

## *Wait for DOM tree*

    domready ->

      dateTime = document.getElementById('dateTime')
      stream = shoe('/dnode')
      d = dnode()
      d.on 'remote', (remote) ->
        setInterval( ->
          remote.dateTime +new Date(), (s) ->
            dateTime.textContent = s
        , 1000)
      d.pipe(stream).pipe d
