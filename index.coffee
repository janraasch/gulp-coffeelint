fs = require 'fs'
map = require 'map-stream'
coffeelint = require 'coffeelint'
configfinder = require 'coffeelint/lib/configfinder'
reporter = require('coffeelint-stylish').reporter
PluginError = (require 'gulp-util').PluginError


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
        try
            opt = JSON.parse fs.readFileSync(opt).toString()
        catch e
            throw new PluginError 'gulp-coffeelint', "Could not load config from file: #{e}"

    map (file, cb) ->
        # pass along
        return cb null, file if file.isNull()

        return cb new PluginError 'gulp-coffeelint', 'Streaming not supported' if file.isStream()

        # if `opt` is not already a JSON `Object`,
        # get config like `coffeelint` cli does.
        opt = configfinder.getConfig file.path if !opt

        results = null
        output = null
        # send results `Array` downstream
        # see http://www.coffeelint.org/#api
        try
            results = coffeelint.lint file.contents.toString('utf8'), opt, literate
        catch e
            newError = new PluginError 'gulp-coffeelint', "Could not lint #{file.path}: #{e}"
            return cb newError

        output = formatOutput results, file, opt, literate
        file.coffeelint = output

        cb null, file

coffeelintPlugin.reporter = ->
    map (file, cb) ->
        # nothing to report or no errors
        return cb null, file if not file.coffeelint or file.coffeelint.success

        # report
        reporter file.relative, file.coffeelint.results

        return cb null, file

module.exports = coffeelintPlugin
