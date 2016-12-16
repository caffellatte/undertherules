### Cakefile ###

### Modules ============================ ###
os            = require'os'                #
jade          = require 'pug'              #
stylus        = require 'stylus'           #
fs            = require 'fs-extra'         #
coffee        = require 'coffee-script'    #
child_process = require 'child_process'    #
### ============================ Modules ###

### Constants ========================= ###
{
  EOL,
  constants,
} = os
### ========================= Constants ###

### Functions ============================== ###
{log}     = console
{exec}    = child_process
{compile} = coffee
{
 arch,
 cpus,
 endianness,
 freemem,
 homedir,
 hostname,
 loadavg,
 networkInterfaces,
 platform,
 release,
 tmpdir,
 totalmem,
 type,
 uptime,
 userInfo,
 
} = os
### ============================== Functions ###


task 'public', 'Create public directory', ->
    log 'public'

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
