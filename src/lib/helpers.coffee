#                            ======================
#                            | src/helpers.coffee |
#                            ======================

### ====================================================================== ###
DatePrettyString = (timestamp, sep=' ') ->                                   #
  zeroPad = (x) ->                                                           #
    return if x < 10 then '0'+x else ''+x                                    #
  date = new Date 1000*timestamp           # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  d = zeroPad date.getDate()              #  Simple coffeescript method to   #
  m = zeroPad date.getMonth()            #  convert a unix timestamp to      #
  y = date.getFullYear()                #  a date. Function return           #
  h = zeroPad date.getHours()          #  example: '2016.03.11 12:26:51'     #
  n = zeroPad date.getMinutes()       #  stackoverflow.com/questions/847185/ #
  s = zeroPad date.getSeconds()      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
  return "#{y}.#{m}.#{d}#{sep}#{h}:#{n++}:#{s}"                              #
### ====================================================================== ###

### ============================================================= ###
NumberFormatter = (num) ->                                          #
  if num > 999 and num < 999999 then (num / 1000).toFixed(1) + 'K'  #
  else if num > 999999 then (num / 1000000).toFixed(1) + 'M'        #
  else num                                                          #
### ============================================================= ###

### ===================================================== ###
module.exports.DatePrettyString = DatePrettyString          #
module.exports.NumberFormatter  = NumberFormatter           #
### ===================================================== ###

#     ===================================================================
#     | Copyright (c) 2016 Mikhail G. Lutsenko (m.g.lutsenko@gmail.com) |
#     |          https://github.com/caffellatte/undertherules           |
#     ===================================================================
