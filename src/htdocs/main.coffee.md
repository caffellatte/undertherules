# main.coffee.md

    domready = require('domready')
    shoe = require('shoe')
    dnode = require('dnode')
    domready ->
      result = document.getElementById('result')
      stream = shoe('/dnode')
      d = dnode()
      d.on 'remote', (remote) ->
        remote.transform 'beep', (s) ->
          result.textContent = 'beep => ' + s
          return
        return
      d.pipe(stream).pipe d
      return
