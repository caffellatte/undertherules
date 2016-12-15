#####################
# uroboros.pp.ua
# compiler.coffee
#####################

#####################
# Modules
fs     = require('fs-extra')
jade   = require('jade')
stylus = require('stylus')
coffee = require('coffee-script')
{exec} = require 'child_process'

coffeeFiles  =
index  = {}
server = {}
index.src  =  'lib/assets/coffee/'
index.lib  =  'public/assets/js/'
server.src =  'lib/index.coffee'
server.lib =  './'

task 'public', 'Create public directory', ->
    fs.mkdirsSync './public/assets/css'
    fs.mkdirsSync './public/assets/js'
    fs.mkdirsSync './public/images'
    console.log 'public'

task 'coffee', 'Build coffee-script files from source files', ->
    console.log 'coffee-script'
    exec "coffee --compile --output #{server.lib} #{server.src}", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr
    exec "coffee --bare --compile --output #{index.lib} #{index.src}", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr

task 'jade', 'Build jade template files from source files', ->
    console.log 'jade'
    exec "jade -P lib/assets/jade/index.jade -o public/", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr

task 'stylus', 'Build stylus files from source files', ->
    console.log 'stylus'
    exec "stylus lib/assets/stylus/ --out public/assets/css", (err, stdout, stderr) ->
        throw err if err
        console.log stdout + stderr

task 'build', 'Coffee-script + Jade + Stylus', ->
    invoke 'public'
    invoke 'coffee'
    invoke 'jade'
    invoke 'stylus'
