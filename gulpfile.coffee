'use strict'

fs = require 'fs'
{spawn} = require 'child_process'
gulp = require 'gulp'
coffee = require 'gulp-coffee'
clean = require 'gulp-clean'
{log,colors} = require 'gulp-util'

# compile `index.coffee`
gulp.task 'coffee', ->
    gulp.src 'index.coffee'
        .pipe coffee bare: true
        .pipe gulp.dest './'

# remove `index.js` and `coverage` dir
gulp.task 'clean', ->
    gulp.src ['index.js', 'coverage'], read: false
        .pipe clean()

# run tests
gulp.task 'test', ['coffee'], ->
    spawn 'npm', ['test'], stdio: 'inherit'

# run `gulp-coffeelint` for testing purposes
gulp.task 'coffeelint', ->
    coffeelint = require './index.coffee'
    gulp.src './{,test/,test/fixtures/}*.coffee'
        .pipe coffeelint()
        .pipe coffeelint.reporter()

# start workflow
gulp.task 'default', ['coffee'], ->
    gulp.watch ['./{,test/,test/fixtures/}*{.coffee,.json}'], ['test']

# create changelog
gulp.task 'changelog', ->
    changelog = require 'conventional-changelog'
    changelog({
        repository: 'https://github.com/janraasch/gulp-coffeelint'
        version: require('./package.json').version
    }, (err, log) ->
        fs.writeFileSync 'changelog.md', log
    )
