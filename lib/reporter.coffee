'use strict'

through2 = require 'through2'
stylish = require 'coffeelint-stylish'
{createPluginError} = require './utils'

defaultReporter = ->
    through2.obj (file, enc, cb) ->
        c = file.coffeelint
        # nothing to report or no errors AND no warnings
        if not c or c.errorCount is c.warningCount is 0
            @push file
            return cb()

        # report
        stylish.reporter file.relative, file.coffeelint.results

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

reporter = (type = 'default') ->
    return defaultReporter() if type is 'default'
    return failReporter() if type is 'fail'
    return failOnWarningReporter() if type is 'failOnWarning'

    # Otherwise
    throw createPluginError "#{type} is not a valid reporter"

module.exports = reporter
