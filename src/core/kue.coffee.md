kue.coffee
==========

Job (task) processing that include the most part of bakcground work.

## Import NPM modules

    kue        = require 'kue'
    path       = require 'path'
    cluster    = require 'cluster'
    helpers    = require './helpers.coffee'

## Extract functions & constans from modules

    clusterWorkerSize = require('os').cpus().length

    {log}    = console

    {
      parse
    } = require 'url'

    # {
    #   DatePrettyString,
    #   Formatter,
    # } = helpers

    {
      KUE_PORT,
    }                 = process.env

    ### ====================================================================== ###
    sendMessage = (data, done) ->                       # Telegram Send  Message #
      {chatId, text} = data                                                      #
      if !chatId? or !text?                                                      #
        log "Error! [sendMessage] Faild to send messsage: #{text} to #{chatId}." #
        return done(new Error("Error! [sendMessage] Faild to send messsage."))   #
      tg.api.sendMessage chatId, text                                            #
      done()                                                                     #
      return



    ### ============================================================== ###
    if cluster.isMaster                                                  #
      kue.app.listen KUE_PORT, () ->                                     #
        log "Kue started at port: #{KUE_PORT}..."                        #
        return                                                         #
      i = 0                                                              #
      while i < clusterWorkerSize                                        #
        cluster.fork()                                                   #
        i++                                                              #
    else                                                                 #
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ #
      queue.process 'sendMessage', (job, done) ->                        #
        sendMessage job.data, done                                       #
