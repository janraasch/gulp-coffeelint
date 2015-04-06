'use strict'

through2 = require 'through2'
{createPluginError} = require './utils'

reporterStream = (reporterType) ->
    through2.obj (file, enc, cb) ->
        c = file.coffeelint
        # nothing to report or no errors AND no warnings
        if not c or c.errorCount is c.warningCount is 0
            @push file
            return cb()

        # report
        rpt = new reporterType(file.coffeelint.results)
        rpt.publish()

        # pass along
        @push file
        cb()

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

reporter = (type) ->
    return failReporter() if type is 'fail'
    return failOnWarningReporter() if type is 'failOnWarning'

    type ?= 'coffeelint-stylish'
    reporter = loadReporter(type)

    unless typeof reporter is 'function'
        throw createPluginError "#{type} is not a valid reporter"

    return reporterStream(reporter)

loadReporter = (reporter) ->
    return reporter if typeof reporter is 'function'
    if typeof reporter is 'string'
        # Try to load CoffeeLint's build-in reporters
        try
            return require('coffeelint/lib/reporters/' + reporter)

        # Try to load full-path and module reporters
        try
            return require(reporter)

module.exports = reporter
