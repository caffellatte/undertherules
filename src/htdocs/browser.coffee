# browser.coffee

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

# Modules
shoe        = require('shoe')
dnode       = require('dnode')
domready    = require('domready')
querystring = require('querystring')

# Functions
{parse} = require('url')

# Interface
class Interface
  constructor:(Dnode) ->
    @line       = document.getElementById('line')
    @output     = document.getElementById('output')
    @line.onkeypress = @onkeypressCli

## *Authorization* & **Social Networks**
    Dnode.on('remote', (remote) =>
      @remote = remote
      {query} = parse(window.location.href)
      {code, state, _s} = querystring.parse(query)
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
      if _s?
        credentials = query.replace('_s=', '').split(':')
        @createCookie('user', credentials[0], 1)
        @createCookie('pass', credentials[1], 1)
      user = @readCookie('user') # or query.replace('_s=', '').split(':')[0]
      pass = @readCookie('pass') # or query.replace('_s=', '').split(':')[1]
      if user and pass
        @remote.auth(user, pass, (err, session) =>
          if err
            console.log(err)
            return Dnode.end()
          else
            @authorized(session)
        )
    )

  onkeypressCli:(event) =>
    {charCode} = event
    if charCode is 13
      {value} = @line
      @output.innerHTML += "<code class='req'>#{value}</code><br><br>"
      @line.value = ''
      @remote.search(value, (s) =>
        @output.innerHTML += "<code class='rep'>#{s}</code><br><br>"
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

  authorized:(session) ->
    @session = session
    console.log(@session)



domready( ->
  stream = shoe('/dnode')
  Dnode  = dnode()
  Dnode.pipe(stream).pipe(Dnode)
  UI = new Interface(Dnode)
)
