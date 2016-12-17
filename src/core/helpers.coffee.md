helpers.coffee
==============

Helpful functions & constants.

## Import NPM modules

    os        = require 'os'
    request   = require 'request'
    cli_table = require 'cli-table'

## Import environment parameters

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

    SysInfo = ->
      utils = {}

### Extract values into *utils*

      ({"#{util}":"#{stringify(os[util]())}"} for util in osUtils).forEach (item) ->
        for key, value of item
          utils[key] = parse value
      return utils

## Display pretty tables with about os

    DisplaySysInfo = (data) ->
      {
        hostname, loadavg, uptime, freemem, totalmem, cpus,
        type, release, networkInterfaces, arch, platform
      } = data

### Information about hostname, uptime, type, release, arch, platform

      mainTable = new cli_table()
      mainTableArray = [
        {'Hostname': hostname}
        {'Uptime': "#{uptime//60} min."}
        {'Architecture': arch}
        {'Platform (type)': "#{platform} (#{type})"}
        {'Release': release}
      ]
      mainTable.push mainTableArray...

### CPUs information

      numberOfCPUs = cpus.length
      cpusTable = new cli_table(
        { head: ["", "Model", "Speed", "User", "Nice", "Sys", "IDLE", "IRQ"] }
      )
      for i in [0..numberOfCPUs-1]
        {model, speed, times: {user, nice, sys, idle, irq}} = cpus[i]
        cpusTable.push { "CPU ##{i+1}": [model,speed,user,nice,sys,idle,irq]}

### Memory Usage

      memTable = new cli_table({ head: ["", "Free", "Total", "% of Free"] })
      memTable.push {
        'RAM': [
          Formatter freemem, 1024
          Formatter totalmem, 1024
          "#{(freemem/totalmem*100).toFixed(2)}%"
        ]
      }

### Load Average

      loadavgTable = new cli_table({ head: ["","1 min.","5 min.","15 min."] })
      loadavgTable.push {
        'Load Average': [
          loadavg[0].toFixed(3), loadavg[1].toFixed(3), loadavg[2].toFixed(3)
        ]
      }

### Display tables

      log mainTable.toString()
      log cpusTable.toString()
      log memTable.toString()
      log loadavgTable.toString()
      return

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
    module.exports.DisplaySysInfo   = DisplaySysInfo
    module.exports.SysInfo          = SysInfo
    module.exports.Formatter        = Formatter
    module.exports.startText        = startText
    module.exports.aboutText        = aboutText
    module.exports.helpText         = helpText
    module.exports.KueJobHelper     = KueJobHelper

*More*: [undertherules](https://github.com/caffellatte/undertherules)
