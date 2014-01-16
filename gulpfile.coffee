gulp = require 'gulp'
coffee = require 'gulp-coffee'
clean = require 'gulp-clean'
{log,colors} = require 'gulp-util'
{spawn} = require 'child_process'

# compile `index.coffee`
gulp.task 'coffee', ->
    gulp.src('index.coffee')
        .pipe(coffee bare: true)
        .pipe(gulp.dest './')

# remove `index.js` and `coverage` dir
gulp.task 'clean', ->
    gulp.src(['index.js', 'coverage'], read: false)
        .pipe(clean())

# run tests
gulp.task 'test', ['coffee'], ->
    spawn 'npm', ['test'], stdio: 'inherit'

# run `gulp-coffeelint` for testing purposes
gulp.task 'coffeelint', ->
    coffeelint = require './index.coffee'
    gulp.src('./{,test/,test/fixtures/}*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())

# start workflow
gulp.task 'default', ->
    gulp.run 'coffee'

    gulp.watch ['./{,test/,test/fixtures/}*{.coffee,.json}'], (e) ->
        log "File #{e.type} #{colors.magenta e.path}"
        gulp.run 'test'
