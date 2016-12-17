### Cakefile ###

### Modules ============================================== ###
jade          = require 'pug'                                #
stylus        = require 'stylus'                             #
fs            = require 'fs-extra'                           #
cli_table     = require 'cli-table'                          #
coffee        = require 'coffee-script'                      #
child_process = require 'child_process'                      #
helpers       = require './src/lib/core/helpers.coffee.md'   #
### ============================================== Modules ###

### Functions ============================== ###
{log}       = console                          #
{exec}      = child_process                    #
{compile}   = coffee                           #
{Formatter, SystemSummary} = helpers           #
### ============================== Functions ###

task 'os', 'List information about Operation System.', ->
  {
    hostname, loadavg, uptime, freemem, totalmem, cpus,
    type, release, networkInterfaces, arch, platform
  } = SystemSummary()
  # Information about hostname, uptime, type, release, arch, platform
  mainTable = new cli_table()
  mainTableArray = [
    {'Hostname': hostname}
    {'Uptime': "#{uptime//60} min."}
    {'Architecture': arch}
    {'Platform (type)': "#{platform} (#{type})"}
    {'Release': release}
  ]
  mainTable.push mainTableArray...
  log mainTable.toString()
  # CPUs information
  numberOfCPUs = cpus.length
  cpusTable = new cli_table(
    { head:
      [
        # "The number of CPUs: #{numberOfCPUs}",
        "", "Model", "Speed",
        "User", "Nice", "Sys", "IDLE", "IRQ"
      ]
    }
  )
  for i in [0..numberOfCPUs-1]
    {model, speed, times: {user, nice, sys, idle, irq}} = cpus[i]
    cpusTable.push {
      "CPU ##{i+1}": [model, speed, user, nice, sys, idle, irq]
    }
  log cpusTable.toString()
  # Memory Usage
  memTable = new cli_table(
    { head: ["", "Free", "Total", "% of Free"] }
  )
  memTable.push {
    'RAM': [
      Formatter freemem, 1024
      Formatter totalmem, 1024
      "#{(freemem/totalmem*100).toFixed(2)}%"
    ]
  }
  log memTable.toString()
  # Load Average
  loadavgTable = new cli_table(
    { head: ["", "1 minute", "5 minutes", "15 minutes"] }
  )
  loadavgTable.push {
    'Load Average': [
      loadavg[0].toFixed(3), loadavg[1].toFixed(3), loadavg[2].toFixed(3)
    ]
  }
  log loadavgTable.toString()
  # Network Interfaces
  # log networkInterfaces
  return

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
