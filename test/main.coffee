# module dependencies
should = require 'should'
gutil = require 'gulp-util'
path = require 'path'

# SUT
coffeelint = require '../'

describe 'gulp-coffeelint', ->
    describe 'coffeelint()', ->
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

            stream = coffeelint({})

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

        it 'should send bad results', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeah();'

            stream = coffeelint({})

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

