#!/usr/bin/env coffee

UglifyJS = require 'uglify-js'
debug = true

compile = (filePath, cb) ->
  browserify = require 'browserify'
  b = browserify()
  path = require 'path'
  filePath = path.resolve filePath
  b.add filePath
  b.external 'jqwidgets'
  b.external 'noty'
  b.external 'jStorage'
  b.transform 'coffeeify'
  b.transform 'browserify-shim'
  b.transform 'node-lessify'
  b.transform 'brfs'
  opts = {
    debug: debug
  }
  b.bundle(opts, (err, data) ->
    if debug
      cb(err, data)
    else
      if err
        cb(err, null)
        return
      cb(null, UglifyJS.minify(data, {fromString: true}).code)
    )
  
if require.main == module
  path = process.argv[2]
  throw "Usage: compile.coffee <path>" unless path
  compile path, (err, data) ->
    if err
      console.log "Error :(\n#{err}"
    console.log data

module.exports = compile