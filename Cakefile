### Cakefile ###

pug           = require 'pug'
stylus        = require 'stylus'
fs            = require 'fs-extra'
browserify    = require 'browserify'
coffeeify     = require 'coffeeify'
helpers       = require './src/core/helpers.coffee.md'

utf8 = encoding: 'utf8'
templatePug  = "#{__dirname}/src/htdocs/template.pug"
indexHtml    = "#{__dirname}/static/index.html"
styleStyl    = "#{__dirname}/src/htdocs/style.styl"
styleCss     = "#{__dirname}/static/style.css"
mainCoffeeMd = "#{__dirname}/src/htdocs/main.coffee.md"
bundleJs     = "#{__dirname}/static/bundle.js"
svgHtdocs    = "#{__dirname}/src/htdocs/svg"
svgStatic    = "#{__dirname}/static/svg"
_env =
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

task 'os', 'Display information about Operation System.', ->
  DisplaySysInfo SysInfo()

task 'env', 'Add .env, Procfile (foreman) & database folders.', ->
  writeFileSync "#{__dirname}/.env", _env
  writeFileSync "#{__dirname}/Procfile", _Procfile
  mkdirsSync    "#{__dirname}/.db/tg"
  mkdirsSync    "#{__dirname}/.db/vk"

task 'htdocs:static', 'Create (mkdir) `static` folder.', ->
  mkdirsSync "#{__dirname}/static"
  copySync svgHtdocs, svgStatic

task 'htdocs:pug', 'Render (transform) pug template to html', ->
  writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)

task 'htdocs:stylus', 'Render (transform) stylus template to css', ->
  stylus.render readFileSync(styleStyl, utf8), (err, css) ->
    if err then throw err
    writeFileSync styleCss, css
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

task 'htdocs', 'Build client-side app & save into `static` folder.', ->     #
    invoke 'htdocs:static'
    invoke 'htdocs:pug'
    invoke 'htdocs:stylus'
    invoke 'htdocs:browserify'

task 'clean', 'Remove `.env` file, `static` folder & etc.', ->
  [
    "#{__dirname}/.env"
    "#{__dirname}/static"
    "#{__dirname}/Procfile"
    "#{__dirname}/Procfile"
  ].forEach (item) -> removeSync item
