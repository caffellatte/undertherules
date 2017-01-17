# dnode.coffee.md

Dnode uses the streaming interface provided by shoe, which is just
a thin wrapper on top of sockjs that provides websockets with fallbacks.

## Import NPM modules

    fs         = require 'fs-extra'
    kue        = require 'kue'
    pug        = require 'pug'
    http       = require 'http'
    shoe       = require 'shoe'
    dnode      = require 'dnode'
    stylus     = require 'stylus'
    coffeeify  = require 'coffeeify'
    browserify = require 'browserify'

## Extract functions & constans from modules

    {log} = console
    {writeFileSync, readFileSync, mkdirsSync, copySync} = fs

## Environment virables

    {PANEL_PORT} = process.env
    {PANEL_HOST} = process.env
    {STATIC_DIR} = process.env
    {HTDOCS_DIR} = process.env

## Files & folders

    staticImg         = "#{STATIC_DIR}/img"
    staticFaviconIco  = "#{STATIC_DIR}/favicon.ico"
    indexHtml         = "#{STATIC_DIR}/index.html"
    styleCss          = "#{STATIC_DIR}/style.css"
    bundleJs          = "#{STATIC_DIR}/bundle.js"
    htdocsImg         = "#{HTDOCS_DIR}/img"
    htdocsFaviconIco  = "#{HTDOCS_DIR}/img/favicon.ico"
    templatePug       = "#{HTDOCS_DIR}/template.pug"
    styleStyl         = "#{HTDOCS_DIR}/style.styl"
    dashCoffeeMd      = "#{HTDOCS_DIR}/dash.coffee.md"

## HtdocsStatic

    HtdocsStatic = (data, done) ->
      {STATIC_DIR ,htdocsFaviconIco, staticFaviconIco, htdocsImg, staticImg} = data
      mkdirsSync STATIC_DIR
      log "make folder #{STATIC_DIR}"
      copySync htdocsImg, staticImg
      log "copy folder #{htdocsImg} -> #{staticImg}"
      copySync htdocsFaviconIco, staticFaviconIco
      log "copy file #{htdocsFaviconIco} -> #{staticFaviconIco}"
      done()

##  HtdocsPug

    HtdocsPug = (data, done) ->
      {templatePug, indexHtml} = data
      writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)
      log "render file #{templatePug} -> #{indexHtml}"
      done()

## HtdocsStylus

    HtdocsStylus = (data, done) ->
      {styleStyl, styleCss} = data
      handler = (err, css) ->
        if err then throw err
        writeFileSync styleCss, css
        log "render file #{styleStyl} -> #{styleCss}"
      content = readFileSync(styleStyl, {encoding:'utf8'})
      stylus.render(content, handler)
      done()

## HtdocsBrowserify

    HtdocsBrowserify = (data, done) ->
      {dashCoffeeMd, bundleJs} = data
      bundle = browserify
        extensions: ['.coffee.md']
      bundle.transform coffeeify,
        bare: false
        header: false
      bundle.add dashCoffeeMd
      bundle.bundle (error, js) ->
        throw error if error?
        writeFileSync bundleJs, js
        log "render file #{dashCoffeeMd} -> #{bundleJs}"
        done()

## Create a queue instance for creating jobs, providing us access to redis etc

    queue = kue.createQueue()

### Queue **HtdocsStatic** handler

    queue.process 'HtdocsStatic', (job, done) ->
      HtdocsStatic job.data, done

### Queue **HtdocsPug** handler

    queue.process 'HtdocsPug', (job, done) ->
      HtdocsPug job.data, done

### Queue **HtdocsStylus** handler

    queue.process 'HtdocsStylus', (job, done) ->
      HtdocsStylus job.data, done

### Queue **HtdocsBrowserify** handler

    queue.process 'HtdocsBrowserify', (job, done) ->
      HtdocsBrowserify job.data, done

## A simple static file server middleware. Using it with a raw http server

    ecstatic = require('ecstatic')(STATIC_DIR)

## Create HTTP static server

    server = http.createServer(ecstatic)

## Define API object providing integration vith dnode

    API =
      dateTime: (s, cb) ->
        cb(currentDateTime)
      search: (s, cb) ->
        log(s)
        cb(s)
      auth: (query, cb) ->
        if typeof cb != 'function'
          return
        credentials = query.replace('_s=', '').split(':')
        if credentials[0]? and credentials[1]?
          AuthUserJob = queue.create('AuthenticateUser',
            title: "Authenticate user. Telegram UID: #{credentials[0]}.",
            chatId: credentials[0]).save()
          AuthUserJob.on 'complete', (result) ->
            {user, pass, first_name, last_name} = result
            if +credentials[0] is +user and credentials[1] is pass
              console.log "signed as: #{first_name} #{last_name}"
              cb null, result
            else
              cb 'ACCESS DENIED'
        else
           cb 'ACCESS DENIED'


## Start Dnode

    server.listen PANEL_PORT, ->
      log("""
      RPC module (dnode) successful started. Listen port: #{PANEL_PORT}.
      Web: http://#{PANEL_HOST}:#{PANEL_PORT}
      """)

## Generate stitc files

### Create **HtdocsStatic** Job

      HtdocsStaticJob = queue.create('HtdocsStatic',
        title: "Copy images from HTDOCS_DIR to STATIC_DIR",
        STATIC_DIR:STATIC_DIR,
        htdocsFaviconIco:htdocsFaviconIco,
        staticFaviconIco:staticFaviconIco,
        htdocsImg:htdocsImg
        staticImg:staticImg).delay(100).save()

### Create **HtdocsPug** Job

      HtdocsPugJob = queue.create('HtdocsPug',
        title: "Render (transform) pug template to html",
        templatePug:templatePug,
        indexHtml:indexHtml).delay(1500).save()

### Create **HtdocsStylus** Job

      HtdocsStylusJob = queue.create('HtdocsStylus',
        title: "Render (transform) stylus template to css",
        styleStyl:styleStyl,
        styleCss:styleCss).delay(1500).save()

### Create **HtdocsBrowserify** Job

      HtdocsBrowserifyJob = queue.create('HtdocsBrowserify',
        title: "Render (transform) coffee template to js"
        dashCoffeeMd:dashCoffeeMd,
        bundleJs:bundleJs).delay(1500).save()

## Use dnode via shoe & Install endpoint

    sock = shoe((stream) ->
      d = dnode(API)
      d.pipe(stream).pipe(d)
    )
    sock.install(server, '/dnode')
