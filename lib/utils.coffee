'use strict'

{PluginError} = require 'gulp-util'

exports.isLiterate = (file) ->
    /\.(litcoffee|coffee\.md)$/.test file

exports.createPluginError = (message) ->
    new PluginError 'gulp-coffeelint', message

exports.formatOutput = (errorReport, opt, literate) ->
    errs = 0
    warns = 0

    # some counting
    for path, errors of errorReport.paths
        for error in errors
            errs++ if error.level is 'error'
            warns++ if error.level is 'warn'

    # output
    success: errs is 0
    results: errorReport
    errorCount: errs
    warningCount: warns
    opt: opt
    literate: literate
