helpers.coffee
==============

Helpful functions & constants.

## Import NPM modules

    os        = require 'os'
    request   = require 'request'

## Export environment parameters

    { KUE_PORT, STATIC_PATH } = process.env

## Extract functions from modules

    { log } = console
    { stringify, parse } = JSON

## Texts & other string content

    helpText =
      """
      /start - Create profile.
      /help - Usage tips.
      /track - Track media.
      /find - Explore networks.
      /list - Analyze data.
      /about - cooperate together.
      /config - Customize setting.
      """

    startText =
      """
      Software provides nimble web-data operations.
      Current state: Demo. Usage: /help. More: /about.
      """

    aboutText =
      """
      Undertherules, MIT license
      Copyright (c) 2016 Mikhail G. Lutsenko
      Package: https://github.com/caffellatte/undertherules
      Mail: m.g.lutsenko@gmail.com
      Telegram: @sociometrics
      """

## OS utility methods array

    osUtils = [
      'hostname', 'loadavg', 'uptime', 'freemem',
      'totalmem', 'cpus', 'type', 'release',
      'networkInterfaces', 'arch', 'platform'
    ]

## Extract information about OS
The os module provides a number of operating system-related utility methods.

    SystemSummary = ->
      utils = {}

### Extract values into *utils*

      ({"#{util}":"#{stringify(os[util]())}"} for util in osUtils).forEach (item) ->
        for key, value of item
          utils[key] = parse value
      return utils

## Class for managing Kue jobs via HTTP API

    class KueJobHelper
      constructor: () ->
        @url     = "http://localhost:#{KUE_PORT}/job"
        @headers = 'Content-Type': 'application/json'
        @method  = 'POST'
      create: (type, data, options) ->
        requestData =
          url:     @url
          headers: @headers
          method:  @method
        requestData.json =
          type: type
          data:
            title: "StartHandler. [#{data.chat.id}]: #{data.text}"
            text: data.text
            chat: data.chat
          options:
            attempts: options.attempts
            priority: options.priority
            delay:   options.delay
        request requestData, (error, response, body) ->
          if error
            log JSON.stringify error,null,2
            return
          else
            log "[helpers.coffee] OK, #{body.message}. Kue id: #{body.id}"
            return
          return

## Timestamp to pretty date transform
Simple coffeescript method to  convert a unix timestamp to  a date.
Function return example: '2016.03.11 12:26:51'
[Source](http://stackoverflow.com/questions/847185/)

    DatePrettyString = (timestamp, sep=' ') ->
      zeroPad = (x) ->
        return if x < 10 then '0'+x else ''+x
      date = new Date 1000*timestamp
      d = zeroPad date.getDate()
      m = zeroPad date.getMonth()
      y = date.getFullYear()
      h = zeroPad date.getHours()
      n = zeroPad date.getMinutes()
      s = zeroPad date.getSeconds()
      return "#{y}.#{m}.#{d}#{sep}#{h}:#{n++}:#{s}"

## Formatter for big numbers
* 999 < num < 999999 add postfix *K*
* For num > 999999 add postfix *M*

    Formatter = (num, base = 1000) ->
      if num > 999 and num < 999999 then (num / base).toFixed(1) + 'K'
      else if num > 999999 then (num / (base * base)).toFixed(1) + 'M'
      else num

## Exports functions & constants

    module.exports.DatePrettyString = DatePrettyString
    module.exports.SystemSummary    = SystemSummary
    module.exports.Formatter        = Formatter
    module.exports.startText        = startText
    module.exports.aboutText        = aboutText
    module.exports.helpText         = helpText
    module.exports.KueJobHelper     = KueJobHelper

*More*: [undertherules](https://github.com/caffellatte/undertherules)
