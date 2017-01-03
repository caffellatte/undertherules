# honeycomb.coffee.md

Data agregetion via level-graph storage

## Import NPM modules

    multilevel = require 'multilevel'
    level      = require 'level'
    path       = require 'path'
    net        = require 'net'

## Extract functions & constans from modules

    {LEVEL_PORT} = process.env
    {log}  = console
    {join} = path
