'use strict'

fs = require 'fs'
{spawn} = require 'child_process'
gulp = require 'gulp'
coffee = require 'gulp-coffee'
del = require 'del'
{log,colors} = require 'gulp-util'

# compile `index.coffee` and `lib/*.coffee` files
gulp.task 'coffee', ->
    gulp.src ['{,lib/}*.coffee', '!gulpfile.coffee']
        .pipe coffee bare: true
        .pipe gulp.dest './'

# remove `index.js`, `lib/*.js` and `coverage` dir
gulp.task 'clean', ->
    del ['index.js', 'lib/*.js', 'coverage']

# run tests
gulp.task 'test', ['coffee'], ->
    spawn 'npm', ['test'], stdio: 'inherit'

# run `gulp-coffeelint` for testing purposes
gulp.task 'coffeelint', ->
    coffeelint = require './index.coffee'
    gulp.src './{,lib/,test/,test/fixtures/}*.coffee'
        .pipe coffeelint()
        .pipe coffeelint.reporter()

# start workflow
gulp.task 'default', ['coffee'], ->
    gulp.watch ['./{,lib/,test/,test/fixtures/}*{.coffee,.json}'], ['test']
