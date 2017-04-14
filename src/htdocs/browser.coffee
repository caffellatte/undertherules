# browser.coffee

# Modules
url         = require('url')
shoe        = require('shoe')
dnode       = require('dnode')
request     = require('request')
domready    = require('domready')
querystring = require('querystring')

# Prototypes
Number::padLeft = (base, chr) ->
  len = String(base or 10).length - (String(this).length) + 1
  if len > 0 then new Array(len).join(chr or '0') + this else this

# Browser
class Browser

  createGuid:(giud = '') ->
    nav = window.navigator
    screen = window.screen
    guid = nav.mimeTypes.length
    guid += nav.userAgent.replace(/\D+/g, '')
    guid += nav.plugins.length
    guid += screen.height or ''
    guid += screen.width or ''
    guid += screen.pixelDepth or ''
    return(guid)

  createDate:(d = new Date()) ->
    dformat = [
      (d.getMonth() + 1).padLeft()
      d.getDate().padLeft()
      d.getFullYear()
    ].join('/') + ' ' + [
      d.getHours().padLeft()
      d.getMinutes().padLeft()
      d.getSeconds().padLeft()
    ].join(':')
    return(dformat)

  inputReturn:(event) =>
    {charCode} = event
    if charCode is 13
      {value} = @line
      @line.value = ''
      @remote.inputMessage(@id, value, (s) =>
        node = document.createElement('LI')
        textnode = document.createTextNode(s)
        node.appendChild(textnode)
        @messages[@messages.length - 1].appendChild(node)
      )
      return false
    return

  createCookie:(name, value, days) ->
    expires = ''
    if days
      date = new Date()
      date.setTime(date.getTime() + days * 24 * 60 * 60 * 1000)
      expires = '; expires=' + date.toUTCString()
    document.cookie = name + '=' + value + expires + '; path=/'
    return

  readCookie:(name) ->
    nameEQ = name + '='
    ca = document.cookie.split(';')
    i = 0
    while i < ca.length
      c = ca[i]
      while c.charAt(0) is ' '
        c = c.substring(1, c.length)
      if c.indexOf(nameEQ) is 0
        return c.substring(nameEQ.length, c.length)
      i += 1
    null

  eraseCookie:(name) ->
    createCookie(name, '', -1)
    return

  remoteHandler:(remote) =>
    @remote = remote
    {query, path} = url.parse(window.location.href)
    {id, code, state} = querystring.parse(query)
    if code and state
      [first, ..., last] = state.split(',')
      switch first
        when 'vk'
          sendCodeData = {
            network:first
            code:code
            chatId:last
          }
          @remote.sendCode(sendCodeData, (s) ->
            console.log(s)
          )
    if id
      @remote.dnodeSingIn(id, (err, session) =>
        if err
          console.log(err)
        else
          @id = session.graphId
          console.log('id:', @id)
          @update(@remote)
      )
    else
      guid = @createGuid()
      @remote.dnodeSingUp(guid, (err, session) ->
        if err
          console.log(err)        # return Dnode.end()
        else
          redirectLink = "http://192.168.8.100:8294/?id=#{session.graphId}"
          window.location.assign(redirectLink)
      )

  update:(remote) =>
    remote.dnodeUpdate(@id, (s) =>
      text = document.createElement('CODE')
      node = document.createElement('LI')
      textnode = document.createTextNode(s)
      text.appendChild(textnode)
      node.appendChild(text)
      @messages[@messages.length - 1].appendChild(node)
    )

  constructor:(Dnode) ->
    @line     = document.getElementById('line')
    @messages = document.getElementsByClassName('messages')
    @line.onkeypress = @inputReturn
    Dnode.on('remote', @remoteHandler)



domready( ->
  stream = shoe('/dnode')
  Dnode  = dnode()
  Dnode.pipe(stream).pipe(Dnode)
  UI = new Browser(Dnode)
)
