#                            ======================
#                            |   src/kue.coffee   |
#                            ======================

### ==================================== ###
multilevel = require 'multilevel'          #
level      = require 'level'               #
path       = require 'path'                #
net        = require 'net'                 #
### ==================================== ###

### ========================== ###
{ LEVEL_PORT } = process.env     #
### ========================== ###

### ============= ###
{log}  = console    #
{join} = path       #
### ============= ###

### ================================================================ ###
db = level join( __dirname, '..', 'db-users'), {valueEncoding:'json'}  #
### ================================================================ ###

### ======================================== ###
net.createServer((con) ->                      #
  con.pipe(multilevel.server(db)).pipe con     #
  return                                       #
).listen LEVEL_PORT                            #
### ======================================== ###

#     ===================================================================
#     | Copyright (c) 2016 Mikhail G. Lutsenko (m.g.lutsenko@gmail.com) |
#     |        https://github.com/caffellatte/undertherules             |
#     ===================================================================
