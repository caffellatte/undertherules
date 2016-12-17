### Cakefile ###

### Modules ============================================== ###
pug           = require 'pug'                                #
stylus        = require 'stylus'                             #
fs            = require 'fs-extra'                           #
browserify    = require 'browserify'
coffeeify     = require 'coffeeify'
helpers       = require './src/core/helpers.coffee.md'       #
### ============================================== Modules ###

### Consts ================================================== ###
utf8 = encoding: 'utf8'
templatePug  = "#{__dirname}/src/htdocs/template.pug"
indexHtml    = "#{__dirname}/static/index.html"
styleStyl    = "#{__dirname}/src/htdocs/style.styl"
styleCss     = "#{__dirname}/static/style.css"
mainCoffeeMd = "#{__dirname}/src/htdocs/main.coffee.md"
bundleJs     = "#{__dirname}/static/bundle.js"
svgHtdocs    = "#{__dirname}/src/htdocs/svg"
svgStatic    =  "#{__dirname}/static/svg"
_env =
  """
  KUE_PORT=#{Math.floor(Math.random() * (8999 - 8001) + 8001)}
  STATIC_PATH="#{__dirname}/static/"
  """
_Procfile = "dnode: coffee #{__dirname}/src/core/dnode.coffee.md"
### ================================================== Consts ###

### Functions ===================================================== ###
{log}       = console                                                 #
{Formatter, SysInfo, DisplaySysInfo} = helpers                        #
{writeFileSync, readFileSync, removeSync, mkdirsSync, copySync} = fs  #
### ===================================================== Functions ###

### OS ====================================================== ###
task 'os', 'Display information about Operation System.', ->    #
  DisplaySysInfo SysInfo()                                      #
### ====================================================== OS ###

### .env & Procfile ================================================== ###
task 'env', 'Create .env & Procfile for using with node-foreman.', ->    #
  writeFileSync "#{__dirname}/.env", _env                                #
  writeFileSync "#{__dirname}/Procfile", _Procfile                       #
### ================================================== .env & Procfile ###

### htdocs ============================================================== ###
task 'htdocs', 'Build client-side app & save into `static` folder.', ->     #
  mkdirsSync 'static'                              # Create `static` folder #
  writeFileSync indexHtml, pug.renderFile(templatePug, pretty:true)  # Pug  #
  stylus.render readFileSync(styleStyl, utf8), (err, css) ->       # Stylus #
    if err then throw err                                                   #
    writeFileSync styleCss, css                                             #
  bundle = browserify
    extensions: ['.coffee.md']
  bundle.transform coffeeify,
    bare: false
    header: false
  bundle.add mainCoffeeMd
  bundle.bundle (error, js) ->
    throw error if error?
    writeFileSync bundleJs, js
  copySync svgHtdocs, svgStatic
### ============================================================== htdocs ###

### clean ======================================================= ###
task 'clean', 'Remove `.env` file, `static` folder & etc.', ->      #
  [
    "#{__dirname}/.env"
    "#{__dirname}/static"
    "#{__dirname}/Procfile"
  ].forEach (item) -> removeSync item              #
### ======================================================= clean ###


# task 'build', 'Coffee-script + Jade + Stylus', ->
    # invoke 'public'
    # invoke 'coffee'
    # invoke 'jade'
    # invoke 'stylus'
