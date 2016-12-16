#                            ======================
#                            | src/helpers.coffee |
#                            ======================

### ========================== ###
request  = require 'request'     #
{ log } = console                #
{ KUE_PORT } = process.env       #
### ========================== ###

### ========================== ###
helpText = # Bot commands
  """
  /start - Create profile.
  /help - Usage tips.
  /track - Track media.
  /find - Explore networks.
  /list - Analyze data.
  /about - cooperate together.
  /config - Customize setting.
  """
### ========================== ###

### ============================================== ###
startText =
  """
  Software provides nimble web-data operations.
  Current state: MVP. Usage: /help. More: /about.
  """
### ============================================== ###

### ============================================== ###
aboutText =
  """
  Undertherules, MIT license
  Copyright (c) 2016 Mikhail G. Lutsenko
  Package: http://npmjs.com/package/undertherules
  Mail: m.g.lutsenko@gmail.com
  Telegram: @sociometrics
  """
### ============================================== ###

### ================================================================= ###
class KueJobHelper                                                      #
  constructor: () ->                                                    #
    @url     = "http://localhost:#{KUE_PORT}/job"                       #
    @headers = 'Content-Type': 'application/json'                       #
    @method  = 'POST'                                                   #
  create: (type, data, options) ->                                      #
    requestData =                                                       #
      url:     @url                                                     #
      headers: @headers                                                 #
      method:  @method                                                  #
    requestData.json =                                                  #
      type: type                                                        #
      data:                                                             #
        title: "StartHandler. [#{data.chat.id}]: #{data.text}"          #
        text: data.text                                                 #
        chat: data.chat                                                 #
      options:                                                          #
        attempts: options.attempts                                      #
        priority: options.priority                                      #
        delay:   options.delay                                          #
    request requestData, (error, response, body) ->                     #
      if error                                                          #
        log JSON.stringify error,null,2                                 #
        return                                                          #
      else                                                              #
        log "[helpers.coffee] OK, #{body.message}. Kue id: #{body.id}"  #
        return                                                          #
      return                                                            #
### ================================================================= ###

### ======================================================================== ###
DatePrettyString = (timestamp, sep=' ') ->                                     #
  zeroPad = (x) ->                                                             #
    return if x < 10 then '0'+x else ''+x                                      #
  date = new Date 1000*timestamp              # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  d = zeroPad date.getDate()                  # Simple coffeescript method to  #
  m = zeroPad date.getMonth()                 # convert a unix timestamp to    #
  y = date.getFullYear()                      # a date. Function return        #
  h = zeroPad date.getHours()      # ~~~~~~~~ # example: '2016.03.11 12:26:51' #
  n = zeroPad date.getMinutes()    # http://stackoverflow.com/questions/847185/#
  s = zeroPad date.getSeconds()    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  return "#{y}.#{m}.#{d}#{sep}#{h}:#{n++}:#{s}"                                #
### ======================================================================== ###

### ============================================================= ###
Formatter = (num) ->                                                #
  if num > 999 and num < 999999 then (num / 1000).toFixed(1) + 'K'  #
  else if num > 999999 then (num / 1000000).toFixed(1) + 'M'        #
  else num                                                          #
### ============================================================= ###

### ============================================================ ###
# Node.js, Require and Exports                                     #
# http://openmymind.net/2012/2/3/Node-Require-and-Exports/         #
module.exports.DatePrettyString = DatePrettyString                 #
module.exports.Formatter        = Formatter                        #
module.exports.startText        = startText                        #
module.exports.aboutText        = aboutText                        #
module.exports.helpText         = helpText                         #
module.exports.KueJobHelper     = KueJobHelper                     #
### ============================================================ ###

#     ===================================================================
#     | Copyright (c) 2016 Mikhail G. Lutsenko (m.g.lutsenko@gmail.com) |
#     |          https://github.com/caffellatte/undertherules           |
#     ===================================================================
