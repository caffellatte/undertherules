# honeycomb.coffee.md

Data agregetion via level-graph storage

## Import NPM modules

    fs         = require 'fs-extra'
    kue        = require 'kue'
    http       = require 'http'
    level      = require 'levelup'
    crypto     = require 'crypto'
    levelgraph = require 'levelgraph'

## Extract functions & constans from modules

    {log}           = console
    {ensureDirSync} = fs

## Environment virables

    {LEVEL_DIR}  = process.env
    {LEVEL_PORT} = process.env
    {PANEL_PORT} = process.env
    {PANEL_HOST} = process.env

## Create Level Dir folder

    ensureDirSync LEVEL_DIR

## Create a queue instance for creating jobs

    queue = kue.createQueue()

### Create User

    CreateUser = (data, queue, done) ->
      {chatId, chat, text} = data
      {id, type, username, first_name, last_name} = chat
      triple =
        subject: id
        predicate: 'start'
        object: +new Date()
        type: type
        username: username
        first_name: first_name
        last_name: last_name
      users.get { subject: id, predicate: 'start' }, (err, list) =>
        if err
          done(err)
        else
          switch list.length
            when 1
              job = queue.create('sendMessage',
                title: "Profile already exists. ID: #{chatId}."
                chatId: chatId
                text: "#{text}Profile already exists ID: #{chatId}").save()
              done()
            when 0
              users.put triple, (err) ->
                if not err
                  job = queue.create('sendMessage',
                    title: "Create new profile. ID: #{chatId}."
                    chatId: chatId
                    text: "#{text}Create new profile. ID: #{chatId}.").save()
                  done()
                else
                  done(err)
            else
              done('err')

### Create Session

    CreateSession = (data, queue, done) ->
      {chatId, text} = data
      users.get { subject: chatId, predicate: 'start' }, (err, list) ->
        if err
          done(err)
        else
          if list.length is 1
            {predicate, object, type, username, first_name, last_name} = list[0]
            pass = crypto.createHash('md5').update("#{object}").digest("hex")
            job = queue.create('sendMessage',
              title: "Generate access link. Telegram UID: #{chatId}."
              chatId: chatId
              text: text + "http://#{PANEL_HOST}:#{PANEL_PORT}/?_s=#{chatId}:#{pass}").save()
            done()
          else
            done('err')

## Authenticate User

    AuthenticateUser = (data, queue, done) ->
      {chatId} = data
      users.get { subject: chatId, predicate: 'start' }, (err, list) ->
        if err
          done(err)
        else
          if list.length is 1
            {subject, object, type, username, first_name, last_name} = list[0]
            pass = crypto.createHash('md5').update("#{object}").digest("hex")
            done(null,
              user:subject,
              pass:pass,
              first_name:first_name,
              last_name:last_name,
              username:username,
              type:username
            )
          else
            done('err')


###  Queue **CreateUser** process

    queue.process 'CreateUser', (job, done) ->
      CreateUser job.data, queue, done

###  Queue **CreateSession** process

    queue.process 'CreateSession', (job, done) ->
      CreateSession job.data, queue, done

###  Queue **AuthenticateUser** process

    queue.process 'AuthenticateUser', (job, done) ->
      AuthenticateUser job.data, queue, done

## Initializing usersDB

    db = level(LEVEL_DIR + '/users')
    users = levelgraph db

## Start Dnode & listen Level Port

    server = http.createServer (req,res) ->
      res.setHeader('Content-Type', 'text/html')
      res.writeHead(200, {'Content-Type': 'text/plain'})
      db.db.approximateSize '0', 'z', (err, size) ->
        if err
          log err
        else
          stats = db.db.getProperty('leveldb.stats')
          sstables = db.db.getProperty('leveldb.sstables')
          res.end("\n#{stats}\n#{sstables}\n#{size} bytes.")

    server.listen LEVEL_PORT, ->
      log("""
      LevelGraph module successful started. Listen port: #{LEVEL_PORT}.
      Web: http://0.0.0.0:#{LEVEL_PORT}
      """)
