### Cakefile ###

pug           = require 'pug'
stylus        = require 'stylus'
fs            = require 'fs-extra'
browserify    = require 'browserify'
coffeeify     = require 'coffeeify'
helpers       = require './src/core/helpers.coffee.md'

utf8 = {encoding:'utf8'}
templatePug     = "#{__dirname}/src/htdocs/template.pug"
indexHtml       = "#{__dirname}/static/index.html"
styleStyl       = "#{__dirname}/src/htdocs/style.styl"
styleCss        = "#{__dirname}/static/style.css"
mainCoffeeMd    = "#{__dirname}/src/htdocs/main.coffee.md"
bundleJs        = "#{__dirname}/static/bundle.js"
svgHtdocs       = "#{__dirname}/src/htdocs/svg"
svgStatic       = "#{__dirname}/static/svg"
helpersCoffeeMd = "#{__dirname}/src/core/helpers.coffee.md"
helpersCoffeeMd = "#{__dirname}/src/core/helpers.coffee.md"
Procfile        = "#{__dirname}/Procfile"
_dbVk           = "#{__dirname}/.db/vk"
_dbTg           = "#{__dirname}/.db/tg"
_static         = "#{__dirname}/static"
_env            = "#{__dirname}/.env"
env =
  """
  DNODE_PORT=#{Math.floor(Math.random() * (8499 - 8001) + 8001)}
  KUE_PORT=#{Math.floor(Math.random() * (8999 - 8500) + 8500)}
  STATIC_PATH="#{__dirname}/static/"
  """
_Procfile =
  """
  hive: coffee #{__dirname}/src/core/hive.coffee.md
  """

{log}       = console
{exec}      = require 'child_process'
{Formatter, SysInfo, DisplaySysInfo} = helpers
{writeFileSync, readFileSync, removeSync, mkdirsSync, copySync} = fs

task 'hint', 'JavaScript Source Code Analyzer via coffee-jshint', ->
  command = 'coffeelint ' + helpersCoffeeMd
  exec command, (err, stdout, stderr) ->
    log('coffeelint ', helpersCoffeeMd)
    log(stdout, stderr)

task 'os', 'Display information about Operation System.', ->
  DisplaySysInfo SysInfo()

task 'env', 'Add .env, Procfile (foreman) & database folders.', ->
  writeFileSync _env, env
  log "write file #{_env}"
  writeFileSync Procfile, _Procfile
  log "write file #{Procfile}"

  mkdirsSync _dbVk
  log "make dir   #{_dbVk}"
  mkdirsSync _dbTg
  log "make dir   #{_dbTg}"

task 'htdocs:static', 'Create (mkdir) `static` folder.', ->
  mkdirsSync _static
  log "make folder #{_static}"

task 'htdocs:pug', 'Render (transform) pug template to html', ->
  writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)
  log "render file #{templatePug} -> #{indexHtml}"

task 'htdocs:stylus', 'Render (transform) stylus template to css', ->
  handler = (err, css) ->
    if err then throw err
    writeFileSync styleCss, css
    log('read file ', styleStyl, '} -> ', styleCss)
  content = readFileSync(styleStyl, utf8)
  stylus.render(content, handler)
                                                 #
task 'htdocs:browserify', 'Render (transform) coffee template to js', ->
  bundle = browserify
    extensions: ['.coffee.md']
  bundle.transform coffeeify,
    bare: false
    header: false
  bundle.add mainCoffeeMd
  bundle.bundle (error, js) ->
    throw error if error?
    writeFileSync bundleJs, js
    log "write file #{bundleJs} -> #{js}"

task 'htdocs', 'Build client-side app & save into `static` folder.', ->     #
    invoke 'htdocs:static'
    invoke 'htdocs:pug'
    invoke 'htdocs:stylus'
    invoke 'htdocs:browserify'

task 'clean', 'Remove `.env` file, `static` folder & etc.', ->
  [
    _env
    _static
    Procfile
  ].forEach (item) ->
    removeSync item
    log "removeSync #{item}"
