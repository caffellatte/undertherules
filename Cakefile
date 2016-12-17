### Cakefile ###

### Modules ============================================== ###
pug           = require 'pug'                                #
stylus        = require 'stylus'                             #
fs            = require 'fs-extra'                           #
coffee        = require 'coffee-script'                      #
child_process = require 'child_process'                      #
helpers       = require './src/core/helpers.coffee.md'       #
### ============================================== Modules ###

### Consts ================================================== ###
templatePug = "#{__dirname}/src/htdocs/template.pug"
indexHtml   = "#{__dirname}/static/index.html"
styleStyl   = "#{__dirname}/src/htdocs/style.styl"
styleCss    = "#{__dirname}/static/style.css"
_env =
  """
  KUE_PORT=#{Math.floor(Math.random() * (8999 - 8001) + 8001)}
  STATIC_PATH="#{__dirname}/static/"
  """
utf8 = encoding: 'utf8'
### ================================================== Consts ###

### Functions =========================================== ###
{log}       = console                                       #
{exec}      = child_process                                 #
{compile}   = coffee                                        #
{Formatter, SysInfo, DisplaySysInfo} = helpers              #
{writeFileSync, readFileSync, removeSync, mkdirsSync} = fs  #
### =========================================== Functions ###

### OS ====================================================== ###
task 'os', 'Display information about Operation System.', ->    #
  DisplaySysInfo SysInfo()                                      #
### ====================================================== OS ###

### .env ======================================================= ###
task 'env', 'Create .env file with environment parameters.', ->    #
  writeFileSync '.env', _env                                       #
### ======================================================= .env ###

### htdocs ============================================================== ###
task 'htdocs', 'Build client-side app & save into `static` folder.', ->     #
  mkdirsSync 'static'                              # Create `static` folder #
  writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)  # Pug  #
  stylus.render readFileSync(styleStyl, utf8), (err, css) ->       # Stylus #
    if err then throw err                                                   #
    writeFileSync styleCss, css                                             #
### ============================================================== htdocs ###

### clean ======================================================= ###
task 'clean', 'Remove `.env` file, `static` folder & etc.', ->      #
  ['.env', 'static'].forEach (item) -> removeSync item              #
### ======================================================= clean ###


# task 'build', 'Coffee-script + Jade + Stylus', ->
    # invoke 'public'
    # invoke 'coffee'
    # invoke 'jade'
    # invoke 'stylus'
