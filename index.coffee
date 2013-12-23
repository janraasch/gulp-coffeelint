fs = require 'fs'
es = require 'event-stream'
coffeelint = require 'coffeelint'
gutil = require 'gulp-util'
reporter = require 'coffeelint-stylish'

formatOutput = (results, file, opt, literate) ->
    # no error
    return success: true if results.length is 0

    errs = 0
    warns = 0

    # some counting
    results.map (result) ->
        {level} = result
        errs++ if level is 'error'
        warns++ if level is 'warn'

    output =
        success: false
        results: results
        errorCount: errs
        warningCount: warns
        opt: opt
        literate: literate


coffeelintPlugin = (opt = {}, literate = false) ->
    # load config from file
    if typeof opt is 'string'
        gutil.log "Loading '#{gutil.colors.cyan 'coffeelint'}' config from #{gutil.colors.magenta opt}"
        try
            opt = JSON.parse fs.readFileSync(opt).toString()
        catch e
            throw new Error("gulp-coffeelint: Could not load config from file #{filename}: #{e}")

    es.map (file, cb) ->
        results = null
        output = null
        # send results `Array` downstream
        # see http://www.coffeelint.org/#api
        try
            results = coffeelint.lint String(file.contents), opt, literate
        catch e
            newError = new Error("gulp-coffeelint: Could not lint #{file.path}: #{e}")
            return cb newError

        output = formatOutput results, file, opt, literate
        file.coffeelint = output

        cb null, file

coffeelintPlugin.reporter = ->
    es.map (file, cb) ->
        # nothing to report or no errors
        return cb null, file if not file.coffeelint or file.coffeelint.success

        # report
        reporter file.relative, file.coffeelicoffeelint-stylishs

        return cb null, file

module.exports = coffeelintPlugin
