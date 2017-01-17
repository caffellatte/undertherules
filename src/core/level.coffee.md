# honeycomb.coffee.md

Data agregetion via level-graph storage

## Import NPM modules

    fs         = require 'fs-extra'
    kue        = require 'kue'
    dnode      = require 'dnode'
    level      = require 'levelup'
    levelgraph = require 'levelgraph'

## Extract functions & constans from modules

    {log}        = console
    {mkdirsSync} = fs

## Environment virables

    {LEVEL_DIR}  = process.env
    {LEVEL_PORT} = process.env

## Create Level Dir folder

    levelDir = (data, queue, done) =>
      {LEVEL_DIR} = data
      mkdirsSync LEVEL_DIR
      log "make dir #{LEVEL_DIR}"
      done()

## Create a queue instance for creating jobs

    queue = kue.createQueue()

###  Queue **levelDir** process

    queue.process 'levelDir', (job, done) ->
      levelDir job.data, queue, done

### Create **levelDir** Job

    levelDirJob = queue.create('levelDir',
      title: "Create dir for LevelDB.",
      LEVEL_DIR:LEVEL_DIR).save()

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

## Initializing usersDB

    users = levelgraph(level(LEVEL_DIR + '/users'))

## Start Dnode & listen Level Port

    server = dnode(API)
    server.listen(LEVEL_PORT)
