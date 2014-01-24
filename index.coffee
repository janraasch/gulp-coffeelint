fs = require 'fs'
through2 = require 'through2'
coffeelint = require 'coffeelint'
configfinder = require 'coffeelint/lib/configfinder'
stylish = require 'coffeelint-stylish'
PluginError = (require 'gulp-util').PluginError

createPluginError = (message) ->
    new PluginError 'gulp-coffeelint', message


formatOutput = (results, opt, literate) ->
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


coffeelintPlugin = (opt = null, literate = 'auto', rules = []) ->
    # register custom rules
    rules.map (rule) ->
        if typeof rule isnt 'function'
            throw createPluginError(
                "Custom rules need to be of type function, not #{typeof rule}"
            )
        coffeelint.registerRule rule

    # if `opt` is a string, we load the config (for all files) directly.
    if typeof opt is 'string'
        try
            opt = JSON.parse fs.readFileSync(opt).toString()
        catch e
            throw createPluginError "Could not load config from file: #{e}"

    through2.obj (file, enc, cb) ->
        # pass along
        if file.isNull()
            @push file
            return cb()

        if file.isStream()
            @emit 'error', createPluginError 'Streaming not supported'
            return cb()

        # if `opt` is not already a JSON `Object`,
        # get config like `coffeelint` cli does.
        opt = configfinder.getConfig file.path if !opt

        results = null
        output = null

        if literate is 'auto'
            currentLiterate = false
            for ext in ['.litcoffee', '.coffee.md']
                currentLiterate = true if file.path.slice(-(ext.length)) is ext
        else
            currentLiterate = !!literate

        # get results `Array`
        # see http://www.coffeelint.org/#api
        # for format
        results = coffeelint.lint(
            file.contents.toString(enc),
            opt,
            currentLiterate
        )

        output = formatOutput results, opt, currentLiterate
        file.coffeelint = output

        @push file
        cb()

coffeelintPlugin.reporter = ->
    reporter = stylish.reporter

    through2.obj (file, enc, cb) ->
        # nothing to report or no errors
        if not file.coffeelint or file.coffeelint.success
            @push file
            return cb()

        # report
        reporter file.relative, file.coffeelint.results

        # pass along
        @push file
        cb()

module.exports = coffeelintPlugin
