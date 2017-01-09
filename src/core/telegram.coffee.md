# telegram.coffee.md

## Import NPM modules

    kue        = require('kue')
    dnode      = require('dnode')
    helpers    = require('./helpers.coffee.md')
    Telegram   = require('telegram-node-bot')

## Extract functions & constans from modules

    {log}                              = console
    {TELEGRAM_TOKEN}                   = process.env
    {TextCommand}                      = Telegram
    {OtherwiseController}              = helpers
    {briefHandler, helpHandler}        = helpers
    {startHandler, aboutHandler}       = helpers
    {panelHandler, watchHandler}       = helpers
    {StartController, HelpController}  = helpers
    {WatchController, BriefController} = helpers
    {PanelController, AboutController} = helpers

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

## Create Telegram instance interface

    tg = new Telegram.Telegram TELEGRAM_TOKEN, {workers: 1}

## Telegram onMaster

    tg.onMaster () =>

### Dnode Server Listen

      queue.process 'start',       (job, done) -> startHandler job.data, done
      queue.process 'watch',       (job, done) -> watchHandler job.data, done
      queue.process 'brief',       (job, done) -> briefHandler job.data, done
      queue.process 'about',       (job, done) -> aboutHandler job.data, done
      queue.process 'config',      (job, done) -> panelHandler job.data, done
      queue.process 'help',        (job, done) -> helpHandler  job.data, done
      queue.process 'sendMessage', (job, done) ->
        {chat, text} = job.data
        if !chat? or !text?
          log "Error! [sendMessage] Faild to send messsage: #{text} to #{chat}."
          return Error("Error! [sendMessage] Faild to send messsage.")
        tg.api.sendMessage chat, text
        done()

## Telegram Bot Router

    tg.router
      .when new TextCommand('start', 'startCommand'), new StartController()
      .when new TextCommand('watch', 'watchCommand'), new WatchController()
      .when new TextCommand('brief', 'briefCommand'), new BriefController()
      .when new TextCommand('about', 'aboutCommand'), new AboutController()
      .when new TextCommand('panel', 'panelCommand'), new PanelController()
      .when new TextCommand('help',  'helpCommand'),  new HelpController()
      .otherwise new OtherwiseController()

## More: [undertherules](https://github.com/caffellatte/undertherules)
