# level.coffee.md

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
            done(err)

## SaveTokens

    SaveTokens = (data, queue, done) ->
      {access_token, expires_in,user_id,email,chatId,first} = data
      log access_token, expires_in,user_id,email,chatId
      triple =
        subject: chatId
        predicate: expires_in
        object: user_id
        network: first
        email: email
        access_token: access_token
      tokens.put triple, (err) ->
        if err
          done(new Error("Error! SaveTokens. #{triple}"))
        else
          queue.create('sendMessage',
          title: "Send support text. Telegram UID: #{chatId}."
          chatId: chatId
          text: "Token saved.").save()
        done()

## GetTokens

    GetTokens = (data, queue, done) ->
    {chatId} = data
    tokens.get { subject: chatId }, (err, list) ->
      if err
        done(err)
      else
        if list
          done(list)
        else
          done(err)

###  Queue **CreateUser** process

    queue.process 'CreateUser', (job, done) ->
      CreateUser job.data, queue, done

###  Queue **CreateSession** process

    queue.process 'CreateSession', (job, done) ->
      CreateSession job.data, queue, done

###  Queue **AuthenticateUser** process

    queue.process 'AuthenticateUser', (job, done) ->
      AuthenticateUser job.data, queue, done

### Queue **SaveTokens** process

    queue.process 'SaveTokens', (job, done) ->
      SaveTokens job.data, queue, done

### Queue **GetTokens** process

    queue.process 'GetTokens', (job, done) ->
      GetTokens job.data, queue, done


## Initializing usersDB

    users   = levelgraph(level(LEVEL_DIR + '/users'))
    tokens  = levelgraph(level(LEVEL_DIR + '/tokens'))
    history = levelgraph(level(LEVEL_DIR + '/history'))

## Start Dnode & listen Level Port

    server = http.createServer (req,res) ->
      res.setHeader('Content-Type', 'text/html')
      res.writeHead(200, {'Content-Type': 'text/plain'})
      res.end("ok\n\n.")

    server.listen LEVEL_PORT, ->
      log("""
      LevelGraph module successful started. Listen port: #{LEVEL_PORT}.
      Web: http://0.0.0.0:#{LEVEL_PORT}
      """)

## **Clean** static folder on exit

    exitHandler = (options, err) =>
      if err
        log err.stack
      if options.exit
        process.exit()
        return
      if options.cleanup
        log 'cleanup'

### **do something when app is closing**

    process.on 'exit', exitHandler.bind(null, cleanup: true)

### **catches ctrl+c event**

    process.on 'SIGINT', exitHandler.bind(null, exit: true)

### **catches uncaught exceptions**

    process.on 'uncaughtException', exitHandler.bind(null, exit: true)
