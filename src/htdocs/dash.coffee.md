# main.coffee.md

## Import NPM modules

    shoe     = require 'shoe'
    dnode    = require 'dnode'
    domready = require 'domready'
    {parse}  = require 'url'

## Class Interface

    class Interface

### **Constructor**

      constructor: (Dnode) ->

### *Get Elements*

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
        @cliFlag   = 'none'
        @authFlag  = 'none'

### *addEventListeners*

        window.addEventListener 'resize', @onresize
        @watch.onclick = @displayCli
        @line.onkeypress = @search

### *Authorization*

        Dnode.on 'remote', (remote) =>
          @remote = remote
          user = @readCookie 'user'
          pass = @readCookie 'pass'
          if user and pass
            @remote.auth user, pass, (err, session) =>
              if err
                console.log err
                return Dnode.end()
              else
                console.log session
          else
            {query} = parse(window.location.href)
            if query? and '_s' in query
              credentials = query.replace('_s=', '').split(':')
              if credentials.length is 2
                @createCookie 'user', credentials[0], 1
                @createCookie 'pass', credentials[1], 1
              else
                @unauthorized()
                return Dnode.end()
            else
              @unauthorized()
              return Dnode.end()


                  # @authorized session

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
        cliStyle = "display:#{@cliFlag};width:#{cliWidth}px;"
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
        # logoImg
        logoImgSize = barHeight - 7
        logoImgStyle = "height:#{logoImgSize}px;width:#{logoImgSize}px;"
        @logoImg.setAttribute('style', logoImgStyle)
        # logo
        logoSize = barHeight - 2
        @logo.setAttribute('style', "height:#{logoSize}px;width:#{logoSize}px;")

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

      displayCli: =>
        if @cli.style.display is 'none'
          @cliFlag = 'block'
        else
          @cliFlag = 'none'
        @grid()
        outputHeight = @size.height - (@size.difWidth + @bar.offsetHeight + @input.offsetHeight)
        @output.setAttribute('style', "height:#{outputHeight}px;")
        @line.focus() if @cliFlag is 'block'

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

### **authorized**

      authorized: (session) ->
        console.log session

### **unauthorized**

      unauthorized: () ->
        mainStyle = "display:#{@authFlag};"
        @main.setAttribute('style', mainStyle)
        # window.location.href = ''
        console.log 'unauthorized'


## Wait for DOM tree, after using  Dnode & Shoe

    domready ->
      stream = shoe('/dnode')
      Dnode  = dnode()
      Dnode.pipe(stream).pipe(Dnode)
      UI = new Interface(Dnode)
      UI.onresize()
