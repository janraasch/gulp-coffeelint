gulp = require 'gulp'
coffee = require 'gulp-coffee'
{spawn} = require 'child_process'

# compile `.coffee`
gulp.task 'coffee', ->
    gulp.src(['./*.coffee', '!./gulpfile.coffee'])
        .pipe(coffee bare: true)
        .pipe(gulp.dest './')

# run tests
gulp.task 'test', ['coffee'], ->
    spawn 'npm', ['test'], stdio: 'inherit'

# run `gulp-coffeelint` for testing purposes
gulp.task 'coffeelint', ->
    coffeelint = require './index.coffee'
    gulp.src('./*.coffee')
        .pipe(coffeelint(''))
        .pipe(coffeelint.reporter())

# workflow
gulp.task 'default', ->
    gulp.run 'coffee'

    gulp.watch ['./*.coffee', '!./gulpfile.coffee'], ->
        gulp.run 'test'

    gulp.watch ['./test/*'], ->
        gulp.run 'test'
