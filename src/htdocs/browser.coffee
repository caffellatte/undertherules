# browser.coffee

# Modules
shoe        = require 'shoe'
dnode       = require 'dnode'
domready    = require 'domready'
querystring = require 'querystring'

# Functions
{parse} = require 'url'

# Interface
class Interface
  constructor: (Dnode) ->
    @main       = document.getElementById('main')
    @input      = document.getElementById('input')
    @line       = document.getElementById('line')
    @output     = document.getElementById('output')
    @cli        = document.getElementById('cli')
    @bar        = document.getElementById('bar')
    @logoImg    = document.getElementById('logoImg')
    @logo       = document.getElementById('logo')
    @cliFlag    = 'none'
    @authFlag   = 'none'
    window.addEventListener 'resize', @onresize
    @logo.onclick = @displayCli
    @line.onkeypress = @onkeypressCli

## *Authorization* & **Social Networks**
    Dnode.on 'remote', (remote) =>
      @remote = remote
      {query} = parse(window.location.href)
      {code, state, _s} = querystring.parse query
      if code and state
        [first, ..., last] = state.split(',')
        switch first
          when 'vk'
            sendCodeData =
              network:first
              code:code
              chatId:last
            @remote.sendCode sendCodeData, (s) ->
              console.log s
      if _s?
        credentials = query.replace('_s=', '').split(':')
        @createCookie 'user', credentials[0], 1
        @createCookie 'pass', credentials[1], 1
      user = @readCookie 'user' || query.replace('_s=', '').split(':')[0]
      pass = @readCookie 'pass' || query.replace('_s=', '').split(':')[1]
      if user and pass
        @remote.auth user, pass, (err, session) =>
          if err
            console.log err
            @unauthorized()
            return Dnode.end()
          else
            @authorized session

  onresize: =>
    @size =
      width:   window.innerWidth # || document.body.clientWidth
      height: window.innerHeight # || document.body.clientHeight
      difWidth: window.innerWidth - document.body.clientWidth
      difHeight: window.innerHeight - document.body.clientHeight
    @grid()

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
    # logoImg
    logoImgSize = barHeight - 3
    logoImgStyle = "height:#{logoImgSize}px;width:#{logoImgSize}px;"
    @logoImg.setAttribute('style', logoImgStyle)
    # logo
    logoSize = barHeight - 3
    @logo.setAttribute('style', "height:#{logoSize}px;width:#{logoSize}px;padding-left:3px;padding-top:1px;")

  onkeypressCli: (event) =>
    {charCode} = event
    if charCode is 13
      {value} = @line
      @output.innerHTML += "<code class='req'>#{value}</code><br><br>"
      @line.value = ''
      @remote.search value, (s) ->
        @output.innerHTML += "<code class='rep'>#{s}</code><br><br>"
      return false
    return

  displayCli: =>
    if @cli.style.display is 'none'
      @cliFlag = 'block'
    else
      @cliFlag = 'none'
    @grid()
    outputHeight = @size.height - (@size.difWidth + @bar.offsetHeight + @input.offsetHeight)
    @output.setAttribute('style', "height:#{outputHeight}px;")
    @line.focus() if @cliFlag is 'block'

  createCookie: (name, value, days) ->
    expires = ''
    if days
      date = new Date
      date.setTime date.getTime() + days * 24 * 60 * 60 * 1000
      expires = '; expires=' + date.toUTCString()
    document.cookie = name + '=' + value + expires + '; path=/'
    return

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

  eraseCookie: (name) ->
    createCookie name, '', -1
    return

  authorized: (session) ->
    @session = session
    console.log @session

  unauthorized: () ->
    mainStyle = "display:#{@authFlag};"
    @main.setAttribute('style', mainStyle)
    window.location.href = 'http://t.me/UnderTheRulesBot'
    console.log 'unauthorized'

domready ->
  stream = shoe('/dnode')
  Dnode  = dnode()
  Dnode.pipe(stream).pipe(Dnode)
  UI = new Interface(Dnode)
  UI.onresize()
