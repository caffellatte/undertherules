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

    {LEVEL_PORT} = process.env
    {PANEL_PORT} = process.env
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

## Dnode Crypto

    DnodeCrypto = (subject, object) ->
      nub = +new Date() // (1000 * 60 * 60 * 24)
      _a = subject % nub + nub * subject
      _b = object % subject + object % nub + subject % nub + (object - subject) // nub
      _login = subject * nub
      _passwd = crypto.createHash('md5').update("#{_b}#{subject}#{_a}#{object}").digest("hex")
      return {user: _login, pass: _passwd}

## cake htdocStatic

    HtdocsStatic = (data, done) ->
      {htdocsFaviconIco, staticFaviconIco, htdocsImg, staticImg} = data
      copySync htdocsImg, staticImg
      log "copy folder #{htdocsImg} -> #{staticImg}"
      copySync htdocsFaviconIco, staticFaviconIco
      log "copy file #{htdocsFaviconIco} -> #{staticFaviconIco}"
      done()

# #cake pug

    HtdocsPug = (data, done) ->
      {templatePug, indexHtml} = data
      writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)
      log "render file #{templatePug} -> #{indexHtml}"
      done()

## cake stylus

    HtdocsStylus = (data, done) ->
      {styleStyl, styleCss} = data
      handler = (err, css) ->
        if err then throw err
        writeFileSync styleCss, css
        log "render file #{styleStyl} -> #{styleCss}"
      content = readFileSync(styleStyl, {encoding:'utf8'})
      stylus.render(content, handler)
      done()

## cake browserify

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

## Create **static** folder

    mkdirsSync STATIC_DIR
    log "make folder #{STATIC_DIR}"

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

### **dateTime**

      dateTime: (s, cb) ->
        cb(currentDateTime)

### **search**

      search: (s, cb) ->
        log(s)
        cb(s)

### **auth**

      auth: (_user, _pass, cb) ->
        if typeof cb != 'function'
          return
        ld = dnode.connect(LEVEL_PORT)
        ld.on 'remote', (remote) ->
          nub = +new Date() // (1000 * 60 * 60 * 24)
          id = _user / nub
          remote.panel id, (s) ->
            {subject, object} = s
            ld.end()
            {user, pass} = DnodeCrypto subject, object
            if +_user is +user and _pass is pass
              console.log 'signed in: ' + subject
              cb null, subject
            else
              cb 'ACCESS DENIED'
            return



## Start Dnode

    server.listen PANEL_PORT, ->
      log("""
      RPC module (dnode) successful started. Listen port: #{PANEL_PORT}.
      Web: http://0.0.0.0:#{PANEL_PORT}
      """)

## Generate stitc files

### Create **HtdocsStatic** Job

      HtdocsStaticJob = queue.create('HtdocsStatic',
        title: "Copy images from HTDOCS_DIR to STATIC_DIR",
        htdocsFaviconIco:htdocsFaviconIco,
        staticFaviconIco:staticFaviconIco,
        htdocsImg:htdocsImg
        staticImg:staticImg).save()

### Create **HtdocsPug** Job

      HtdocsPugJob = queue.create('HtdocsPug',
        title: "Render (transform) pug template to html"
        templatePug:templatePug,
        indexHtml:indexHtml).save()

### Create **HtdocsStylus** Job

      HtdocsStylusJob = queue.create('HtdocsStylus',
        title: "Render (transform) stylus template to css"
        styleStyl:styleStyl,
        styleCss:styleCss).save()

### Create **HtdocsBrowserify** Job

      HtdocsBrowserifyJob = queue.create('HtdocsBrowserify',
        title: "Render (transform) coffee template to js"
        dashCoffeeMd:dashCoffeeMd,
        bundleJs:bundleJs).save()

## Use dnode via shoe & Install endpoint

    sock = shoe((stream) ->
      d = dnode(API)
      d.pipe(stream).pipe(d)
    )
    sock.install(server, '/dnode')
