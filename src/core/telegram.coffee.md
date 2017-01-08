# telegram.coffee.md

## Import NPM modules

    fs       = require 'fs'
    request  = require 'request'
    _        = require 'lodash'
    helpers  = require './helpers.coffee.md'
    Telegram = require 'telegram-node-bot'

## Extract functions & constans from modules

    {KUE_PORT}      = process.env
    {log}           = console

    {KueJobHelper, DatePrettyString} = helpers
    {helpText, startText, aboutText, Formatter} = helpers
    kueJob = new KueJobHelper()



# Export controllers



## More: [undertherules](https://github.com/caffellatte/undertherules)
