# main.coffee.md

## *Import NPM modules*

    shoe     = require 'shoe'
    dnode    = require 'dnode'
    domready = require 'domready'
    {log}    = console

## *Setting up User Interface*

    class Interface
      constructor: () ->
        dateTime = document.getElementById('recordBlock')
        dateTime = document.getElementById('dateTime')
        stream = shoe('/dnode')
        d = dnode()
        d.on 'remote', (remote) ->
          setInterval( ->
            remote.dateTime +new Date(), (s) ->
              dateTime.textContent = s
          , 1000)
        d.pipe(stream).pipe d
        window.addEventListener 'resize', @onresize
        @onresize()
        @grid()
        searchBlock = document.getElementById('searchBlock')
        searchBlock.append
      onresize: ->
        @size = {
          width: window.innerWidth || document.body.clientWidth,
          height: window.innerHeight || document.body.clientHeight
        }
        document.body.width = @size.width
        document.body.height = @size.height
        log(@size)
      grid: ->
        document.body.style.backgroundImage = "url('svg/grid.svg')"

## *Wait for DOM tree*

    domready ->

      i = new Interface()
