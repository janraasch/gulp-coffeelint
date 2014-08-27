'use strict'

# module dependencies
should = require 'should'
gutil = require 'gulp-util'
path = require 'path'

# const
PLUGIN_NAME = 'gulp-coffeelint'
ERR_MSG =
    RULE:
        'Custom rules need to be of type function, not string'
    CONFIG:
        "Could not load config from file:
 Error: ENOENT, no such file or directory ''"
    STREAM:
        'Streaming not supported'

# fixtures
customRule = require './fixtures/irule'

# SUT
coffeelint = require '../'

describe 'gulp-coffeelint', ->
    describe 'coffeelint()', ->
        it 'should pass through empty file', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: null

            stream = coffeelint()

            stream.on 'data', (newFile) ->
                should.exist(newFile)
                should.exist(newFile.path)
                should.exist(newFile.relative)
                should.not.exist(newFile.contents)
                newFile.path.should.equal './test/fixture/file.js'
                newFile.relative.should.equal 'file.js'
                ++dataCounter

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should pass through the file', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'sure()'

            stream = coffeelint()

            stream.on 'data', (newFile) ->
                should.exist(newFile)
                should.exist(newFile.path)
                should.exist(newFile.relative)
                should.exist(newFile.contents)
                newFile.path.should.equal './test/fixture/file.js'
                newFile.relative.should.equal 'file.js'
                ++dataCounter


            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should pass through two files', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeah()'

            fakeFile2 = new gutil.File
                path: './test/fixture/file2.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeahmetoo()'


            stream = coffeelint()

            stream.on 'data', (newFile) ->
                ++dataCounter

            stream.once 'end', ->
                dataCounter.should.equal 2
                done()

            stream.write fakeFile
            stream.write fakeFile2
            stream.end()

        it 'should send success status', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeah()'

            stream = coffeelint {}

            stream.on 'data', (newFile) ->
                ++dataCounter
                should.exist newFile.coffeelint
                should.exist newFile.coffeelint.success
                newFile.coffeelint.success.should.be.true

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should send success status even when there are warnings', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'debugger'

            stream = coffeelint 'no_debugger': 'level': 'warn'

            stream.on 'data', (newFile) ->
                ++dataCounter
                should.exist newFile.coffeelint
                should.exist newFile.coffeelint.success
                should.exist newFile.coffeelint.warningCount
                should.exist newFile.coffeelint.errorCount
                newFile.coffeelint.success.should.be.true
                newFile.coffeelint.warningCount.should.eql(1)
                newFile.coffeelint.errorCount.should.eql(0)

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should send bad results', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeah();'

            stream = coffeelint {}

            stream.on 'data', (newFile) ->
                ++dataCounter
                should.exist newFile.coffeelint
                should.exist newFile.coffeelint.opt
                newFile.coffeelint.opt.should.be.empty
                newFile.coffeelint.success.should.be.false
                newFile.coffeelint.errorCount.should.equal 1
                newFile.coffeelint.warningCount.should.equal 0
                newFile.coffeelint.results.should.be.an.instanceOf Array
                newFile.coffeelint.results.should.not.be.empty
                # see http://www.coffeelint.org/#api
                newFile.coffeelint.results[0].level.should.equal 'error'
                newFile.coffeelint.results[0].lineNumber.should.equal 1
                should.exist newFile.coffeelint.results[0].message
                should.exist newFile.coffeelint.results[0].description
                should.exist newFile.coffeelint.results[0].rule

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should load explicitly set config and send results', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeah();'

            stream = coffeelint path.join __dirname, './coffeelint.json'

            stream.on 'data', (newFile) ->
                ++dataCounter
                should.exist newFile.coffeelint
                should.exist newFile.coffeelint.opt
                newFile.coffeelint.opt.should.not.be.empty
                newFile.coffeelint.success.should.be.false
                newFile.coffeelint.errorCount.should.equal 1
                newFile.coffeelint.warningCount.should.equal 1
                newFile.coffeelint.results.should.be.an.instanceOf Array
                newFile.coffeelint.results.should.not.be.empty
                # see http://www.coffeelint.org/#api
                newFile.coffeelint.results[0].lineNumber.should.equal 1
                should.exist newFile.coffeelint.results[0].message
                should.exist newFile.coffeelint.results[0].description
                should.exist newFile.coffeelint.results[0].rule
                newFile.coffeelint.results[0].rule.should.equal(
                    'max_line_length'
                )
                should.exist newFile.coffeelint.results[0].context

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'optFile param should overrule opt param', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeah();'

            stream = coffeelint(
                path.join(__dirname, './coffeelint.json'),
                max_line_length: 10
            )

            stream.on 'data', (newFile) ->
                ++dataCounter
                should.exist newFile.coffeelint
                should.exist newFile.coffeelint.opt
                newFile.coffeelint.opt.should.not.be.empty
                newFile.coffeelint.success.should.be.false
                newFile.coffeelint.errorCount.should.equal 1
                newFile.coffeelint.warningCount.should.equal 1
                newFile.coffeelint.results.should.be.an.instanceOf Array
                newFile.coffeelint.results.should.not.be.empty
                # see http://www.coffeelint.org/#api
                newFile.coffeelint.results[0].lineNumber.should.equal 1
                should.exist newFile.coffeelint.results[0].message
                should.exist newFile.coffeelint.results[0].description
                should.exist newFile.coffeelint.results[0].rule
                newFile.coffeelint.results[0].rule.should.equal(
                    'max_line_length'
                )
                should.exist newFile.coffeelint.results[0].context

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should load config as cli does and send results', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeah();'

            stream = coffeelint()

            stream.on 'data', (newFile) ->
                ++dataCounter
                should.exist newFile.coffeelint
                should.exist newFile.coffeelint.opt
                newFile.coffeelint.opt.should.not.be.empty
                newFile.coffeelint.success.should.be.false
                newFile.coffeelint.errorCount.should.equal 1
                newFile.coffeelint.warningCount.should.equal 1
                newFile.coffeelint.results.should.be.an.instanceOf Array
                newFile.coffeelint.results.should.not.be.empty
                # see http://www.coffeelint.org/#api
                newFile.coffeelint.results[0].lineNumber.should.equal 1
                should.exist newFile.coffeelint.results[0].message
                should.exist newFile.coffeelint.results[0].description
                should.exist newFile.coffeelint.results[0].rule
                newFile.coffeelint.results[0].rule.should.equal(
                    'max_line_length'
                )
                should.exist newFile.coffeelint.results[0].context

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        it 'should load custom rule', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'console.log "gulp is awesome"'

            stream = coffeelint({}, [customRule])

            stream.on 'data', (newFile) ->
                ++dataCounter
                should.exist newFile.coffeelint
                should.exist newFile.coffeelint.opt
                newFile.coffeelint.opt.should.be.empty
                newFile.coffeelint.success.should.be.false
                newFile.coffeelint.errorCount.should.equal 1
                newFile.coffeelint.warningCount.should.equal 0
                newFile.coffeelint.results.should.be.an.instanceOf Array
                newFile.coffeelint.results.should.not.be.empty
                # see http://www.coffeelint.org/#api
                newFile.coffeelint.results[0].lineNumber.should.equal 1
                should.exist newFile.coffeelint.results[0].message
                should.exist newFile.coffeelint.results[0].description
                should.exist newFile.coffeelint.results[0].rule
                newFile.coffeelint.results[0].rule.should.equal(
                    'awesome_custom_rule'
                )

            stream.once 'end', ->
                dataCounter.should.equal 1
                done()

            stream.write fakeFile
            stream.end()

        describe 'issue #12', ->
            it 'args-js may modify the `params` parameter', (done) ->
                dataCounter = 0

                fakeFile = new gutil.File
                    path: './test/fixture/file.js',
                    cwd: './test/',
                    base: './test/fixture/',
                    contents: new Buffer 'console.log "gulp is awesome"'

                opt = max_line_length: {value: 1024, level: 'ignore'}

                stream_one = coffeelint opt: opt
                stream_two = coffeelint opt: opt

                stream_two.on 'data', (newFile) ->
                    ++dataCounter
                    should.exist newFile.coffeelint
                    should.exist newFile.coffeelint.opt
                    newFile.coffeelint.opt.should.eql opt

                stream_two.once 'end', ->
                    dataCounter.should.equal 1
                    done()

                stream_two.write fakeFile
                stream_two.end()




        describe 'errors', ->
            describe 'are thrown', ->
                it 'if custom rule is not of type function', (done) ->
                    try
                        stream = coffeelint ['This ain\'t no function']
                    catch e
                        should(e.plugin).equal PLUGIN_NAME
                        should(e.message).equal ERR_MSG.RULE
                        done()

                it 'if config (passed as String) cannot be loaded', (done) ->
                    try
                        stream = coffeelint ''
                    catch e
                        should(e.plugin).equal PLUGIN_NAME
                        should(e.message).equal ERR_MSG.CONFIG
                        done()

            describe 'are emitted', ->
                it 'if file is stream', (done) ->
                    fakeFile = new gutil.File
                        path: './test/fixture/file.js',
                        cwd: './test/',
                        base: './test/fixture/',
                        contents: process.stdin

                    stream = coffeelint()

                    stream.on 'error', (e) ->
                        should(e.plugin).equal PLUGIN_NAME
                        should(e.message).equal ERR_MSG.STREAM
                        done()

                    stream.write fakeFile
                    stream.end()
