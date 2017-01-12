# dnode.coffee.md

## Import NPM modules

    http       = require('http')
    shoe       = require('shoe')
    dnode      = require('dnode')
    coffeeify  = require('coffeeify')
    browserify = require('browserify')
    helpers    = require('./helpers.coffee.md')

## Extract functions & constans from modules

    {DnodeCrypto} = helpers
    {DNODE_PORT, STATIC_PATH, LEVEL_DNODE_PORT} = process.env
    {log}                     = console

## cake htdocStatic

    HtdocsStatic = (_static, imgHtdocs, imgStatic, favicon, _favicon, done) ->
      mkdirsSync _static
      log "make folder #{_static}"
      copySync imgHtdocs, imgStatic
      log "copy folder #{imgHtdocs} -> #{imgStatic}"
      copySync favicon, _favicon
      log "copy file #{favicon} -> #{_favicon}"
      done()

# #cake pug

    Pug = (templatePug, indexHtml, done) ->
      writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)
      log "render file #{templatePug} -> #{indexHtml}"
      done()

## cake stylus

    HtdocsStylus = (styleStyl, styleCss, done) ->
      handler = (err, css) ->
        if err then throw err
        writeFileSync styleCss, css
        log "render file #{styleStyl} -> #{styleCss}"
      content = readFileSync(styleStyl, utf8)
      stylus.render(content, handler)
      done()

## cake browserify

    HtdocsBrowserify = (mainCoffeeMd, bundleJs, done) ->
      bundle = browserify
        extensions: ['.coffee.md']
      bundle.transform coffeeify,
        bare: false
        header: false
      bundle.add mainCoffeeMd
      bundle.bundle (error, js) ->
        throw error if error?
        writeFileSync bundleJs, js
        log "render file #{mainCoffeeMd} -> #{bundleJs}"
        done()


    # task 'htdocs:static', 'Create (mkdir) `static` folder.', ->
    #   HtdocsStatic(_static, imgHtdocs, imgStatic, favicon, _favicon)
    #
    # task 'htdocs:pug', 'Render (transform) pug template to html', ->
    #   Pug(templatePug, indexHtml)
    #
    # task 'htdocs:stylus', 'Render (transform) stylus template to css', ->
    #   HtdocsStylus(styleStyl, styleCss)
    #
    # task 'htdocs:browserify', 'Render (transform) coffee template to js', ->
    #   HtdocsBrowserify(mainCoffeeMd, bundleJs)
    #
    # task 'htdocs', 'Build client-side app & save into `static` folder.', ->
    #   invoke 'htdocs:static'
    #   invoke 'htdocs:pug'
    #   invoke 'htdocs:stylus'
    #   invoke 'htdocs:browserify'

## A simple static file server middleware. Using it with a raw http server

    ecstatic = require('ecstatic')(STATIC_PATH)

## Create HTTP static server

    server = http.createServer(ecstatic)

## Define API object providing integration vith dnode

    API =
      dateTime: (s, cb) ->
        # currentDateTime = DatePrettyString(s)
        cb(currentDateTime)
      search: (s, cb) ->
        log(s)
        cb(s)
      auth: (_user, _pass, cb) ->
        if typeof cb != 'function'
          return
        ld = dnode.connect(LEVEL_DNODE_PORT)
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

    server.listen DNODE_PORT, ->
      log("""
      RPC module (dnode) successful started. Listen port: #{DNODE_PORT}.
      Web: http://0.0.0.0:#{DNODE_PORT}
      """)

## Use dnode via shoe & Install endpoint

    sock = shoe((stream) ->
      d = dnode(API)
      d.pipe(stream).pipe(d)
    )
    sock.install(server, '/dnode')
