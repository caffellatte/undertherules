# main.coffee.md

## Import NPM modules

    shoe     = require 'shoe'
    dnode    = require 'dnode'
    domready = require 'domready'
    {parse}  = require 'url'
    {log}    = console

## Class Interface

    class Interface

### **Constructor**

      constructor: (Dnode) ->
        Dnode.on 'remote', (remote) =>
          @remote = remote
          {query} = parse(window.location.href)
          if query
            credentials = query.replace('_s=', '').split(':')
            if credentials.length is 2
              @createCookie 'user', credentials[0], 1
              @createCookie 'pass', credentials[1], 1
              # window.location.href = ''
          else
            user = @readCookie 'user'
            pass = @readCookie 'pass'
            @remote.auth user, pass, (err, session) ->
              if err
                console.error err
                return Dnode.end()
              else
                log session

*Add Event Listener*

        window.addEventListener 'resize', @onresize

*Get Elements*

        @main      = document.getElementById('main')
        @input     = document.getElementById('input')
        @line      = document.getElementById('line')
        @output    = document.getElementById('output')
        @cli       = document.getElementById('cli')
        @bar       = document.getElementById('bar')
        @logoImg   = document.getElementById('logoImg')
        @watchImg  = document.getElementById('watchImg')
        @logo      = document.getElementById('logo')
        @watch     = document.getElementById('watch')
        @cliTurn   = 'none'

*Search Block onkeypress*

        @watch.onclick = @display
        @line.onkeypress = @search

### **On Resize**

      onresize: =>
        @size =
          width:   window.innerWidth # || document.body.clientWidth
          height: window.innerHeight # || document.body.clientHeight
          difWidth: window.innerWidth - document.body.clientWidth
          difHeight: window.innerHeight - document.body.clientHeight
        @grid()

### **Background Grid**

      grid: =>
        # main
        mainWidth  = @size.width - @size.difWidth
        mainHeight = @size.height - @size.difWidth
        mainStyle  = "width:#{mainWidth}px;height:#{mainHeight}px;"
        @main.setAttribute('style', mainStyle)
        # cli
        mainDif = @main.offsetWidth - @main.clientWidth
        cliWidth = @main.offsetWidth - mainDif
        cliStyle = "display:#{@cliTurn};width:#{cliWidth}px;"
        @cli.setAttribute('style', cliStyle)
        # line
        lineWidth = cliWidth - (2 * mainDif) - 13
        lineStyle = "width: #{lineWidth}px;"
        @line.setAttribute('style', lineStyle)
        # bar
        barHeight = mainHeight // 10
        barStyle = "width:#{cliWidth}px;height:#{barHeight}px;"
        @bar.setAttribute('style', barStyle)
        # background-position
        mainStyle += "background-position: center #{barHeight + 2}px;"
        @main.setAttribute('style', mainStyle)
        # watchImg
        watchImgSize = barHeight - 7
        watchImgStyle = "height:#{watchImgSize}px;width:#{watchImgSize}px;"
        @watchImg.setAttribute('style', watchImgStyle)
        # watch
        watchSize = barHeight - 2
        @watch.setAttribute('style', "height:#{watchSize}px;width:#{watchSize}px;")

### **Search Handler**

      search: (event) =>
        {charCode} = event
        if charCode is 13
          {value} = @line
          @output.innerHTML += "<code class='req'>#{value}</code><br>"
          @line.value = ''
          @remote.search value, (s) ->
            @output.innerHTML += "<code class='rep'>#{s}</code><br>"
          return false
        return

### **Display**

      display: =>
        if @cli.style.display is 'none'
          @cliTurn = 'block'
        else
          @cliTurn = 'none'
        @grid()
        outputHeight = @size.height - (@size.difWidth + @bar.offsetHeight + @input.offsetHeight)
        @output.setAttribute('style', "height:#{outputHeight}px;")
        @line.focus() if @cliTurn is 'block'

### **createCookie**

      createCookie: (name, value, days) ->
        expires = ''
        if days
          date = new Date
          date.setTime date.getTime() + days * 24 * 60 * 60 * 1000
          expires = '; expires=' + date.toUTCString()
        document.cookie = name + '=' + value + expires + '; path=/'
        return

### **readCookie**

      readCookie: (name) ->
        nameEQ = name + '='
        ca = document.cookie.split(';')
        i = 0
        while i < ca.length
          c = ca[i]
          while c.charAt(0) == ' '
            c = c.substring(1, c.length)
          if c.indexOf(nameEQ) == 0
            return c.substring(nameEQ.length, c.length)
          i++
        null

### **eraseCookie**

      eraseCookie: (name) ->
        createCookie name, '', -1
        return

## Wait for DOM tree

    domready ->

## Dnode + Shoe

      stream = shoe('/dnode')
      Dnode  = dnode()
      Dnode.pipe(stream).pipe(Dnode)
      UI = new Interface(Dnode)
      UI.onresize()


      # ## Timestamp to pretty date transform
      # Simple coffeescript method to  convert a unix timestamp to  a date.
      # Function return example: '2016.03.11 12:26:51'
      # http://stackoverflow.com/questions/847185/
      #
      #     DatePrettyString = (timestamp, sep = ' ') ->
      #       zeroPad = (x) ->
      #         return if x < 10 then '0' + x else '' + x
      #       date = new Date(timestamp)
      #       d = zeroPad(date.getDate())
      #       m = +zeroPad(date.getMonth()) + 1
      #       y = date.getFullYear()
      #       h = zeroPad(date.getHours())
      #       n = zeroPad(date.getMinutes())
      #       s = zeroPad(date.getSeconds())
      #       return "#{y}.#{m}.#{d}#{sep}#{h}:#{n}:#{s}"
