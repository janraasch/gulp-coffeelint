'use strict'

fs = require 'fs'
through2 = require 'through2'
Args = require 'args-js' # main entry missing in `args-js` package

# `reporter`
reporter = require './lib/reporter'

# common utils
{isLiterate, createPluginError, formatOutput} = require './lib/utils'

coffeelintPlugin = ->
    # params for `args-js`
    params = [
        {optFile: Args.STRING | Args.Optional}
        {opt: Args.OBJECT | Args.Optional}
        {literate: Args.BOOL | Args.Optional}
        {rules: Args.ARRAY | Args.Optional, _default: []}
        {cjsx: Args.BOOL | Args.Optional}
    ]

    # parse arguments
    try
        {opt, optFile, literate, rules, cjsx} = Args params, arguments
    catch e
        throw createPluginError e

    # sadly an `Args.OBJECT` maybe an `Array`
    # e.g. `coffeelintPlugin [-> myCustomRule]`
    if Array.isArray opt
        rules = opt
        opt = undefined

    # bring in the linter
    coffeelintPkg = if cjsx then 'coffeelint-cjsx' else 'coffeelint'
    coffeelint = require coffeelintPkg
    configfinder = require coffeelintPkg + '/lib/configfinder'

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
        errorReport = coffeelint.getErrorReport()
        errorReport.lint(
            file.relative,
            file.contents.toString(),
            fileOpt,
            fileLiterate
        )

        output = formatOutput errorReport, fileOpt, fileLiterate
        file.coffeelint = output

        @push file
        cb()

coffeelintPlugin.reporter = reporter

module.exports = coffeelintPlugin
