# browser.coffee

# Modules
url         = require('url')
shoe        = require('shoe')
dnode       = require('dnode')
request     = require('request')
domready    = require('domready')
querystring = require('querystring')

# Texts
helpText = '''
  /help - List of commands
  /about - Contacts & links
  /auth - Add social network'''
startText = '''
  Flexible environment for social network analysis (SNA).
  Software provides full-cycle of retrieving and subsequent
  processing data from the social networks.
  Usage: /help. Contacts: /about. Tokens: /auth. Dashboard: /login.'''
aboutText = '''
  Undertherules, MIT license
  Copyright (c) 2016 Mikhail G. Lutsenko
  Github: https://github.com/caffellatte
  Npm: https://www.npmjs.com/~caffellatte
  Telegram: https://telegram.me/caffellatte'''
authText = '''
  Authorization via Social Networks'''

# Interface
class Interface

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

  createJob:(options) ->
    {type, title, params, attempts, priority} = options
    jobOptions = {
      type:type,
      data:{
        title:title,
        params:params
      },
      options:{
        attempts:attempts or 5,
        priority:priority or 'normal'
      }
    }
    postOptions = {
      url:'http://0.0.0.0:8816/job',
      form:jobOptions
    }
    request.post(postOptions, (err, httpResponse, body) ->
      console.log(body)
    )

  inputReturn:(event) =>
    {charCode} = event
    if charCode is 13
      {value} = @line
      @output.innerHTML += "<li class='req'>#{value}</li>"
      @line.value = ''
      @remote.inputMessage(value, (s) =>
        @output.innerHTML += "<li class='resp'><code>#{s}</code></li>"
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
    timestamp = +new Date()
    guid      = @createGuid()
    if timestamp and guid
      @remote.dnodeAuth(id, timestamp, guid, (err, session) ->
        if err
          console.log(err)
          # return Dnode.end()
        else
          console.log(session)
      )

  constructor:(Dnode) ->
    @line   = document.getElementById('line')
    @output = document.getElementById('output')
    @line.onkeypress = @inputReturn
    Dnode.on('remote', @remoteHandler)



domready( ->
  stream = shoe('/dnode')
  Dnode  = dnode()
  Dnode.pipe(stream).pipe(Dnode)
  UI = new Interface(Dnode)
)
