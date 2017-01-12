# helpers.coffee.md

## Timestamp to pretty date transform
Simple coffeescript method to  convert a unix timestamp to  a date.
Function return example: '2016.03.11 12:26:51'
http://stackoverflow.com/questions/847185/

    DatePrettyString = (timestamp, sep = ' ') ->
      zeroPad = (x) ->
        return if x < 10 then '0' + x else '' + x
      date = new Date(timestamp)
      d = zeroPad(date.getDate())
      m = +zeroPad(date.getMonth()) + 1
      y = date.getFullYear()
      h = zeroPad(date.getHours())
      n = zeroPad(date.getMinutes())
      s = zeroPad(date.getSeconds())
      return "#{y}.#{m}.#{d}#{sep}#{h}:#{n}:#{s}"


## Formatter for big numbers
* 999 < num < 999999 add postfix *K*
* For num > 999999 add postfix *M*

    Formatter = (num, base = 1000) ->
      if num > 999 and num < 999999 then (num / base).toFixed(1) + 'K'
      else if num > 999999 then (num / (base * base)).toFixed(1) + 'M'
      else num

## Telegram + Web Auth

    DnodeCrypto = (subject, object) ->
      nub = +new Date() // (1000 * 60 * 60 * 24)
      _a = subject % nub + nub * subject
      _b = object % subject + object % nub + subject % nub + (object - subject) // nub
      _login = subject * nub
      _passwd = crypto.createHash('md5').update("#{_b}#{subject}#{_a}#{object}").digest("hex")
      return {user: _login, pass: _passwd}

## Exports functions & constants

    module.exports.DnodeCrypto         = DnodeCrypto
    module.exports.DatePrettyString    = DatePrettyString
    module.exports.Formatter           = Formatter

## More: [undertherules](https://github.com/caffellatte/undertherules)
