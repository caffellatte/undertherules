sockjs_url = '/echo'
sockjs = new SockJS(sockjs_url)
$('#first input').focus()
div = $('#first div')
inp = $('#first input')
form = $('#first form')

print = (m, p) ->
  p = if p == undefined then '' else JSON.stringify(p)
  div.append $('<code>').text(m + ' ' + p)
  div.append $('<br>')
  div.scrollTop div.scrollTop() + 10000
  return

sockjs.onopen = ->
  print '[*] open', sockjs.protocol
  return

sockjs.onmessage = (e) ->
  print '[.] message', e.data
  return

sockjs.onclose = ->
  print '[*] close'
  return

form.submit ->
  print '[ ] sending', inp.val()
  sockjs.send inp.val()
  inp.val ''
  false
