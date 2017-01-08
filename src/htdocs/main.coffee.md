main.coffee.md
==============

## Import NPM modules

    shoe     = require 'shoe'
    dnode    = require 'dnode'
    domready = require 'domready'
    {log}    = console

## Class Interface

    class Interface

### **Constructor**

      constructor: (Dnode) ->
        Dnode.on 'remote', (remote) =>
          @remote = remote

*Add Event Listener*

        window.addEventListener 'resize', @onresize

*Get Elements*

        @mainBlock   = document.getElementById('mainBlock')
        @searchBlock = document.getElementById('searchBlock')
        @searchLine  = document.getElementById('searchLine')
        @returnBlock = document.getElementById('returnBlock')

*Search Block onkeypress*

        @searchLine.onkeypress = @search
        @searchLine.focus()

### **On Resize**

      onresize: =>
        @size =
          width:   window.innerWidth # || document.body.clientWidth
          height: window.innerHeight # || document.body.clientHeight
          difWidth: window.innerWidth - document.body.clientWidth
          difHeight: window.innerHeight - document.body.clientHeight
        # log 'innerWidth x innerHeight:', window.innerWidth, 'x', window.innerHeight
        log "[client] Width x Height: #{@size.width} (#{@size.difWidth}) x #{@size.height}  (#{@size.difHeight})"
        @grid()

### **Background Grid**

      grid: =>

        # mainBlockStyle   += "height: #{@size.height - (@searchBlock.clientHeight - 0.62 * @searchBlock.clientHeight)}px;" # -
        # returnBlockStyle  = "top: #{@searchBlock.clientHeight}px;"
        # returnBlockStyle += "height: #{mainBlock.clientHeight - (3 * @searchBlock.clientHeight)}px;"
        # returnBlockStyle  = "background-image: url('img/grid1024.png');"
        mainBlockStyle    = "width: #{@size.width - @size.difWidth}px;"
        mainBlockStyle   += "height: #{@size.height - @size.difWidth}px;"
        @mainBlock.setAttribute('style', mainBlockStyle)
        # returnBlockStyle  = "width: #{@mainBlock.offsetWidth // 1.015}px;"
        # searchBlockStyle  = "height: #{@searchBlock.offsetWidth}px;"
        # searchLineStyle   = "width: #{@searchBlock.offsetWidth}px;"
        # @searchLine.setAttribute('style', searchLineStyle)
        # returnBlockStyle += "height: #{@mainBlock.offsetHeight // 1.1 - @searchBlock.offsetHeight}px;"
        # returnBlockStyle += "top: #{@searchBlock.offsetHeight}px;"
        # @returnBlock.setAttribute('style', returnBlockStyle)
        # searchBlockStyle += "height: #{@size.height * 0.38 // 0.99}px;"
        # searchLineStyle  += "height: #{@searchBlock.offsetHeight // 1.015}px;"
        # searchLineStyle  += "width: #{@mainBlock.offsetWidth * 0.985}px;"


        # @searchBlock.setAttribute('style', searchBlockStyle)

### **Search Handler**

      search: (event) =>

        {charCode} = event
        if charCode is 13
          {value} = @searchLine
          @searchLine.value = ''
          @remote.search value, (s) ->
            returnBlock.textContent = s+'!'
          return false
        return

## Wait for DOM tree

    domready ->

## Dnode + Shoe

      stream = shoe('/dnode')
      Dnode  = dnode()
      Dnode.pipe(stream).pipe(Dnode)
      UI = new Interface(Dnode)
      UI.onresize()
