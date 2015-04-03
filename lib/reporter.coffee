'use strict'

through2 = require 'through2'
stylish = require 'coffeelint-stylish'
{createPluginError} = require './utils'

failReporter = ->
    through2.obj (file, enc, cb) ->
        # nothing to report or no errors
        if not file.coffeelint or file.coffeelint.success
            @push file
            return cb()

        # fail
        @emit 'error',
            createPluginError "CoffeeLint failed for #{file.relative}"
        cb()

failOnWarningReporter = ->
    through2.obj (file, enc, cb) ->
        c = file.coffeelint
        # nothing to report or no errors AND no warnings
        if not c or c.errorCount is c.warningCount is 0
            @push file
            return cb()

        # fail
        @emit 'error',
            createPluginError "CoffeeLint failed for #{file.relative}"
        cb()

loadReporter = (reporter) ->
    return reporter if typeof reporter is 'function'
    if typeof reporter is 'object' and typeof reporter.reporter is 'function'
        return reporter.reporter

    if typeof reporter is 'string'
        # Try to load CoffeeLint's build-in reporters
        try
            return loadReporter require('coffeelint/src/reporters/' + reporter)

        # Try to load full-path and module reporters
        try
            return loadReporter require(reporter)

reporter = (type = 'default') ->
    return failReporter() if type is 'fail'
    return failOnWarningReporter() if type is 'failOnWarning'

    rpt = stylish.reporter if type is 'default'
    rpt = loadReporter(type) unless rpt?

    unless typeof rpt is 'function'
        throw createPluginError "#{type} is not a valid reporter"

    # Return stream hooked to the loaded reporter
    through2.obj (file, enc, cb) ->
        c = file.coffeelint
        # nothing to report or no errors AND no warnings
        if not c or c.errorCount is c.warningCount is 0
            @push file
            return cb()

        # report
        rpt file.relative, file.coffeelint.results

        # pass along
        @push file
        cb()

module.exports = reporter
