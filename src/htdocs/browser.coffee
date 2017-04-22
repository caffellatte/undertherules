# browser.coffee

# Modules
url         = require('url')
shoe        = require('shoe')
dnode       = require('dnode')
request     = require('request')
domready    = require('domready')
querystring = require('querystring')

COLORS = [
  '#e21400', '#91580f', '#f8a700', '#f78b00',  '#58dc00', '#287b00',
  '#a8f07a', '#4ae8c4', '#3b88eb', '#3824aa', '#a700ff', '#d300e7'
]

# Texts
helpText = '''
  Flexible environment for social network analysis (SNA).
  Software provides full-cycle of retrieving and subsequent
  processing data from the social networks.
  Usage: /help. Contacts: /about.

  Under The Rules, MIT license
  Copyright (c) 2016 Mikhail G. Lutsenko
  Github: https://github.com/caffellatte
  Npm: https://www.npmjs.com/~caffellatte
  Telegram: https://telegram.me/caffellatte'''

# Welcome to
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

  createDateFullYear:(ts) ->
    d = new Date(ts)
    dformat = [
      (d.getMonth() + 1).padLeft()
      d.getDate().padLeft()
      d.getFullYear()
    ].join('/')
    return(dformat)

  createDate:(ts) ->
    d = new Date(ts)
    dformat = [
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
        node.setAttribute('class', 'log')
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

  sigmaNeighborsHandler:(nodeId) ->
    k = undefined
    neighbors = {}
    index = @allNeighborsIndex[nodeId] or {}
    for k of index
      neighbors[k] = @nodesIndex[k]
    neighbors

  sigmaRender:(id) =>
    divContainer = document.createElement('DIV')
    divContainer.setAttribute('id', 'container')
    @messages[@messages.length - 1].appendChild(divContainer)
    sigma.classes.graph.addMethod('neighbors', @sigmaNeighborsHandler)
    sigma.parsers.json("/files/#{id}.json", {
      container:'container',
      settings:{} # {defaultNodeColor:'#ec5148'}
    }, (s) ->
      # We first need to save the original colors of our
      # nodes and edges, like this:
      s.graph.nodes().forEach((n) ->
        n.originalColor = n.color
        return
      )
      s.graph.edges().forEach((e) ->
        e.originalColor = e.color
        return
      )
      # When a node is clicked, we check for each node
      # if it is a neighbor of the clicked one. If not,
      # we set its color as grey, and else, it takes its
      # original color.
      # We do the same for the edges, and we only keep
      # edges that have both extremities colored.
      s.bind('clickNode', (e) ->
        nodeId = e.data.node.id
        toKeep = s.graph.neighbors(nodeId)
        toKeep[nodeId] = e.data.node
        s.graph.nodes().forEach((n) ->
          if toKeep[n.id]
            n.color = n.originalColor
          else
            n.color = '#eee'
          return
        )
        s.graph.edges().forEach((e) ->
          if toKeep[e.source] and toKeep[e.target]
            e.color = e.originalColor
          else
            e.color = '#eee'
          return
        )
        # Since the data has been modified, we need to
        # call the refresh method to make the colors
        # update effective.
        s.refresh()
        return
      )
      # When the stage is clicked, we just color each
      # node and edge with its original color.
      s.bind('clickStage', (e) ->
        s.graph.nodes().forEach((n) ->
          n.color = n.originalColor
          return
        )
        s.graph.edges().forEach((e) ->
          e.color = e.originalColor
          return
        )
        # Same as in the previous event:
        s.refresh()
        return
      )
      return
    )

  remoteHandler:(remote) =>
    @remote = remote
    {query, path} = url.parse(window.location.href)
    {id, code, state} = querystring.parse(query)
    if id
      @remote.dnodeSingIn(id, null, (err, session) =>
        if err
          console.log(err)
        else
          # welcomeText = document.createTextNode(helpText)
          # welcomeLi = document.createElement('LI')
          # text = document.createElement('CODE')
          # node = document.createElement('LI')
          #
          # textnode = document.createTextNode("#{ts} > #{s.value}")
          # text.appendChild(textnode)
          # node.appendChild(text)
          # @messages[@messages.length - 1].appendChild(node)
          # #
          @id = session.graphId

          emptyHr = document.createElement('HR')
          emptyLi = document.createElement('LI')
          emptyLi.appendChild(emptyHr)
          graphIdCountTextNode = document.createTextNode('')
          graphIdidTextNode = document.createTextNode(@id)
          graphIdA = document.createElement('A')
          graphIdLi = document.createElement('LI')
          graphIdA.appendChild(graphIdidTextNode)
          graphIdA.setAttribute('href', "/?id=#{@id}")
          graphIdLi.appendChild(graphIdA)
          graphIdLi.appendChild(graphIdCountTextNode)
          @messages[@messages.length - 1].appendChild(graphIdLi)
          @messages[@messages.length - 1].appendChild(emptyLi)
          @remote.dnodeUpdate(@id, (s) =>
            if s.key is 'count'
              graphIdCountTextNode.nodeValue = " (#{s.value})"
              emptyHr2 = document.createElement('HR')
              emptyLi2 = document.createElement('LI')
              emptyLi2.appendChild(emptyHr2)
              @messages[@messages.length - 1].appendChild(emptyLi2)
              @sigmaRender(@id)
            else
              linkA = document.createElement('A')
              linkLi = document.createElement('LI')
              linkCode = document.createElement('CODE')
              linkTextNode = document.createTextNode(s.value)
              linkA.appendChild(linkTextNode)
              linkA.setAttribute('href', "/?id=#{s.value}")
              linkA.setAttribute('target', '_blank')
              linkCode.appendChild(linkA)
              linkLi.appendChild(linkCode)
              @messages[@messages.length - 1].appendChild(linkLi)
          )
      )
    else
      guid = @createGuid()
      @remote.dnodeSingUp(guid, (err, session) ->
        if err
          console.log(err)        # return Dnode.end()
        else
          redirectLink = "/?id=#{session.graphId}"
          window.location.assign(redirectLink)
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
