# stylish reporter for `gulp-coffeelint`
# --------------------------------------

# heavily influenced by `jshint-stylish`
# https://github.com/sindresorhus/jshint-stylish

# module dependencies
glog = require('gulp-util').log
chalk = require 'chalk'
table = require 'text-table'

# sign language
isWin = process.platform is 'win32'
warnSign = "#{if isWin then '' else '⚠'}"
errSign = "#{if isWin then '' else '✖'}"

module.exports = (relPath, results) ->
    # keep in mind that
    # this report is not
    # going to be called with
    # an empty results `Array`
    errs = 0
    warns = 0
    ret = ''

    # build log table
    ret += table results.map (result) ->
        {level, lineNumber, message, context} = result
        errs++ if level is 'error'
        warns++ if level is 'warn'

        # return line message
        [
            ''
            chalk.gray if level is 'error' then errSign else warnSign
            chalk.gray 'line ' + lineNumber
            chalk.blue message
            chalk.gray context or ''
        ]

    ret += '\n\n'

    # append summary
    if warns > 0
        ret += chalk.yellow.bold(
            "#{warnSign} #{warns} warning#{if warns is 1 then '' else 's'}"
        )
        ret += '\n' if errs > 0

    if errs > 0
        ret += chalk.red.bold(
            "#{errSign} #{errs} error#{if errs is 1 then '' else 's'}"
        )

    # print headline with leading `[gulp]`
    glog "Linting #{chalk.magenta relPath} with '#{chalk.cyan 'coffeelint'}'"

    # print table and summary line(s)
    console.log ret
