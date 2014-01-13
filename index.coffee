fs = require 'fs'
es = require 'event-stream'
coffeelint = require 'coffeelint'
configfinder = require 'coffeelint/lib/configfinder'
gutil = require 'gulp-util'
reporter = require('coffeelint-stylish').reporter

formatOutput = (results, file, opt, literate) ->
    errs = 0
    warns = 0

    # some counting
    results.map (result) ->
        {level} = result
        errs++ if level is 'error'
        warns++ if level is 'warn'

    # output
    success: if results.length is 0 then true else false
    results: results
    errorCount: errs
    warningCount: warns
    opt: opt
    literate: literate


coffeelintPlugin = (opt = null, literate = false) ->
    # if `opt` is a string, we load the config (for all files) directly.
    if typeof opt is 'string'
        gutil.log "Loading '#{gutil.colors.cyan 'coffeelint'}' config from #{gutil.colors.magenta opt}"
        try
            opt = JSON.parse fs.readFileSync(opt).toString()
        catch e
            throw new Error "gulp-coffeelint: Could not load config from file #{filename}: #{e}"

    es.map (file, cb) ->
        # if `opt` is not already a JSON `Object`,
        # get config like `coffeelint` cli does.
        opt = configfinder.getConfig file.path if !opt

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
        reporter file.relative, file.coffeelint.results

        return cb null, file

module.exports = coffeelintPlugin
