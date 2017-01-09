### Cakefile ###

helpers         = require './src/core/helpers.coffee.md'
{Hint, Env, Pug, HtdocsStatic, HtdocsStylus, HtdocsBrowserify, Clean} = helpers

templatePug     = "#{__dirname}/src/htdocs/template.pug"
indexHtml       = "#{__dirname}/static/index.html"
styleStyl       = "#{__dirname}/src/htdocs/style.styl"
styleCss        = "#{__dirname}/static/style.css"
mainCoffeeMd    = "#{__dirname}/src/htdocs/main.coffee.md"
bundleJs        = "#{__dirname}/static/bundle.js"
imgHtdocs       = "#{__dirname}/src/htdocs/img"
imgStatic       = "#{__dirname}/static/img"
helpersCoffeeMd = "#{__dirname}/src/core/helpers.coffee.md"
hiveCoffeeMd    = "#{__dirname}/src/core/hive.coffee.md"
_Procfile       = "#{__dirname}/Procfile"
_dbVk           = "#{__dirname}/.db/vk"
_dbTg           = "#{__dirname}/.db/tg"
_static         = "#{__dirname}/static"
_env            = "#{__dirname}/.env"
favicon         = "#{__dirname}/src/htdocs/img/favicon.ico"
_favicon        = "#{__dirname}/static/favicon.ico"
env =
  """
  TELEGRAM_TOKEN=""
  DNODE_PORT=#{Math.floor(Math.random() * (8499 - 8001) + 8001)}
  KUE_PORT=#{Math.floor(Math.random() * (8999 - 8500) + 8500)}
  STATIC_PATH="#{__dirname}/static/"
  """
Procfile =
  """
  kue: coffee #{__dirname}/src/core/kue.coffee.md
  telegram: coffee #{__dirname}/src/core/telegram.coffee.md
  dnode: coffee #{__dirname}/src/core/dnode.coffee.md
  """

task 'hint', 'JavaScript Source Code Analyzer via coffee-jshint', ->
  Hint(helpersCoffeeMd, hiveCoffeeMd)

task 'os', 'Display information about Operation System.', ->
  DisplaySysInfo(SysInfo())

task 'env', 'Add .env, Procfile (foreman) & database folders.', ->
  Env(_env, env, _Procfile, Procfile, _dbVk, _dbTg)

task 'clean', 'Remove `.env` file, `static` folder & etc.', ->
  Clean(_env, _static, _Procfile)

task 'htdocs:static', 'Create (mkdir) `static` folder.', ->
  HtdocsStatic(_static, imgHtdocs, imgStatic, favicon, _favicon)

task 'htdocs:pug', 'Render (transform) pug template to html', ->
  Pug(templatePug, indexHtml)

task 'htdocs:stylus', 'Render (transform) stylus template to css', ->
  HtdocsStylus(styleStyl, styleCss)

task 'htdocs:browserify', 'Render (transform) coffee template to js', ->
  HtdocsBrowserify(mainCoffeeMd, bundleJs)

task 'htdocs', 'Build client-side app & save into `static` folder.', ->
  invoke 'htdocs:static'
  invoke 'htdocs:pug'
  invoke 'htdocs:stylus'
  invoke 'htdocs:browserify'
