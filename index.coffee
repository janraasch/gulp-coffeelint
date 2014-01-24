'use strict'

fs = require 'fs'
through2 = require 'through2'
Args = require 'args-js/Args' # main entry missing in `args-js` package
coffeelint = require 'coffeelint'
configfinder = require 'coffeelint/lib/configfinder'
stylish = require 'coffeelint-stylish'
PluginError = (require 'gulp-util').PluginError

isLiterate = (file) ->
    /\.(litcoffee|coffee\.md)$/.test file

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

params = [
    {optFile: Args.STRING | Args.Optional}
    {opt: Args.OBJECT | Args.Optional}
    {literate: Args.BOOL | Args.Optional}
    {rules: Args.ARRAY | Args.Optional, _default: []}
]

coffeelintPlugin = ->
    # parse arguments
    try
        {opt, optFile, literate, rules} = Args params, arguments
    catch e
        throw createPluginError e

    # sadly an `Args.OBJECT` maybe an `Array`
    # e.g. `coffeelintPlugin [-> myCustomRule]`
    if Array.isArray opt
        rules = opt
        opt = undefined

    # register custom rules
    rules.map (rule) ->
        if typeof rule isnt 'function'
            throw createPluginError(
                "Custom rules need to be of type function, not #{typeof rule}"
            )
        coffeelint.registerRule rule

    if toString.call(optFile) is '[object String]'
        try
            opt = JSON.parse fs.readFileSync(optFile).toString()
        catch e
            throw createPluginError "Could not load config from file: #{e}"

    through2.obj (file, enc, cb) ->
        # `file` specific options
        fileOpt = opt
        fileLiterate = literate

        results = null
        output = null

        # pass along
        if file.isNull()
            @push file
            return cb()

        if file.isStream()
            @emit 'error', createPluginError 'Streaming not supported'
            return cb()

        # if `opt` is not already a JSON `Object`,
        # get config like `coffeelint` cli does.
        fileOpt = configfinder.getConfig file.path if fileOpt is undefined

        # if `literate` is not given
        # check for file extension like
        # `coffeelint`cli does.
        fileLiterate = isLiterate(file.path) if fileLiterate is undefined

        # get results `Array`
        # see http://www.coffeelint.org/#api
        # for format
        results = coffeelint.lint(
            file.contents.toString(),
            fileOpt,
            fileLiterate
        )

        output = formatOutput results, fileOpt, fileLiterate
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
