### Cakefile ###

### Modules =========================================== ###
os            = require 'os'                              #
jade          = require 'pug'                             #
stylus        = require 'stylus'                          #
fs            = require 'fs-extra'                        #
cli_table     = require 'cli-table'                       #
coffee        = require 'coffee-script'                   #
child_process = require 'child_process'                   #
helpers       = require './src/lib/core/helpers.coffee'   #
### =========================================== Modules ###

### Constants ============================== ###
osUtils = [                                #
  'hostname', 'loadavg', 'uptime', 'freemem',  #
  'totalmem', 'cpus', 'type', 'release',       #
  'networkInterfaces', 'arch', 'platform'      #
]                                              #
### ============================== Constants ###

### Functions ============================== ###
{log}       = console                          #
{exec}      = child_process                    #
{compile}   = coffee                           #
{Formatter} = helpers                          #
### ============================== Functions ###


task 'os', 'List information about Operation System.', ->
  utils = {}
  ({"#{util}":"#{os[util]()}"} for util in osUtils).forEach (element) ->
    for key, value of element
      utils[key] = value
  {
    hostname, loadavg, uptime, freemem, totalmem, cpus,
    type, release, networkInterfaces, arch, platform
  } = utils
  log "#{hostname}, #{loadavg}"
  # log osUtilsArr...
  # table = new cli_table()
  # table.push osArray...
  # log table.toString()
  # for utility in osData
  #   log osUtilities, utility()
    # log method() if typeof method is 'function' and utility in osUtilities

# task 'public', 'Create public directory', ->
#     fs.mkdirsSync './public/assets/css'
#     fs.mkdirsSync './public/assets/js'
#     fs.mkdirsSync './public/images'
#     log 'public'
#
# task 'coffee', 'Build coffee-script files from source files', ->
#     log 'coffee-script'
#     exec "coffee --compile --output #{server.lib} #{server.src}", (err, stdout, stderr) ->
#         throw err if err
#         log stdout + stderr
#     exec "coffee --bare --compile --output #{index.lib} #{index.src}", (err, stdout, stderr) ->
#         throw err if err
#         log stdout + stderr
#
# task 'jade', 'Build jade template files from source files', ->
#     log 'jade'
#     exec "jade -P lib/assets/jade/index.jade -o public/", (err, stdout, stderr) ->
#         throw err if err
#         log stdout + stderr
#
# task 'stylus', 'Build stylus files from source files', ->
#     log 'stylus'
#     exec "stylus lib/assets/stylus/ --out public/assets/css", (err, stdout, stderr) ->
#         throw err if err
#         log stdout + stderr

# task 'build', 'Coffee-script + Jade + Stylus', ->
    # invoke 'public'
    # invoke 'coffee'
    # invoke 'jade'
    # invoke 'stylus'
