# honeycomb.coffee.md

Data agregetion via level-graph storage

## Import NPM modules

    fs         = require 'fs-extra'
    dnode      = require 'dnode'
    level      = require 'levelup'
    levelgraph = require 'levelgraph'

## Extract functions & constans from modules

    LEVEL_PORT   = process.env.npm_package_config_level_port
    LEVEL_PATH   = process.env.npm_package_config_level_path
    {log}        = console
    {mkdirsSync} = fs

## Create Data folder

    mkdirsSync LEVEL_PATH
    log "make dir #{LEVEL_PATH}"

## Initializing a database

    users = levelgraph(level(LEVEL_PATH + 'users'))

## Inserting a triple in the database

    API =
      start:  (chat, cb) ->
        {id, type, username, first_name, last_name} = chat
        triple =
          subject: id
          predicate: 'start'
          object: +new Date()
          type: type
          username: username
          first_name: first_name
          last_name: last_name
        users.get { subject: id, predicate: 'start' }, (err, list) ->
          if err
            log err
          else
            switch list.length
              when 1
                cb(list[0])
              when 0
                users.put triple, (err) ->
                  if not err
                    cb(triple)
                  else
                    cb(err)
              else
                cb('err')
      panel:  (s, cb) ->
        users.get { subject: s, predicate: 'start' }, (err, list) ->
          if err
            log err
          else
            if list.length is 1
              cb(list[0])
            else
              cb('err')

    server = dnode(API)
    server.listen(LEVEL_PORT)
