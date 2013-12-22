gulp = require 'gulp'
coffee = require 'gulp-coffee'
{spawn} = require 'child_process'

# compile `.coffee`
gulp.task 'coffee', ->
    gulp.src(['./*.coffee', '!./gulpfile.coffee'])
        .pipe(coffee bare: true)
        .pipe(gulp.dest './')

# run tests
gulp.task 'test', ->
    spawn 'npm', ['test'], stdio: 'inherit'

# workflow
gulp.task 'default', ->
    gulp.run 'coffee'

    gulp.watch ['./*.coffee', '!./gulpfile.coffee'], ->
        gulp.run 'coffee', 'test'

    gulp.watch ['./test/*'], ->
        gulp.run 'test'
