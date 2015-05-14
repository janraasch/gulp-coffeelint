'use strict'

{PluginError} = require 'gulp-util'

exports.isLiterate = (file) ->
    /\.(litcoffee|coffee\.md)$/.test file

exports.createPluginError = (message) ->
    new PluginError 'gulp-coffeelint', message

exports.formatOutput = (errorReport, opt, literate) ->
    {errorCount, warningCount} = errorReport.getSummary()

    # output
    success: errorCount is 0
    results: errorReport
    errorCount: errorCount
    warningCount: warningCount
    opt: opt
    literate: literate
