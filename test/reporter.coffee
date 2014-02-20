'use strict'

# module dependencies
gutil = require 'gulp-util'
should = require 'should'
sinon = require 'sinon'

# SUT
coffeelint = require '../'

# globals
reporter_module = require 'coffeelint-stylish'
stub = null

# const
PLUGIN_NAME = 'gulp-coffeelint'
ERR_MSG =
    REPORTER:
        'is not a valid reporter'

describe 'gulp-coffeelint', ->
    describe 'coffeelint.reporter', ->
        it 'throws when passed invalid reporter type', (done) ->
            try
                coffeelint.reporter 'stupid'
            catch e
                should(e.plugin).equal PLUGIN_NAME
                should(e.message).equal "stupid #{ERR_MSG.REPORTER}"
                done()

    describe 'coffeelint.reporter \'default\'', ->
        beforeEach ->
            # reset statistics
            countReporterCalls = 0
            countFileNames = []
            countResults = []

            stub = sinon.stub reporter_module, 'reporter', ->
                'I am a mocking bird'
        afterEach ->
            reporter_module.reporter.restore()

        it 'should pass through a file', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'sure()'

            stream = coffeelint.reporter()

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

        it 'only calls reporter if `file.coffeelint.success===false', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'success()'

            fakeFile.coffeelint = success: true

            fakeFile2 = new gutil.File
                path: './test/fixture/file2.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeahmetoo()'

            fakeFile2.coffeelint = success: false, results: [bugs: 'many']


            stream = coffeelint.reporter()

            stream.on 'data', (newFile) ->
                ++dataCounter

            stream.once 'end', ->
                dataCounter.should.equal 2
                stub.calledOnce.should.equal true
                (should stub.firstCall.args).eql ['file2.js', [bugs: 'many']]
                done()

            stream.write fakeFile
            stream.write fakeFile2
            stream.end()

    describe 'coffeelint.reporter \'fail\'', ->

        it 'should pass through an okay file', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'sure()'

            stream = coffeelint.reporter 'fail'

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

        it 'should not pass thourgh a bad file', (done) ->
            dataCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'sure()'

            fakeFile.coffeelint = success: false, results: [bugs: 'many']

            stream = coffeelint.reporter 'fail'

            stream.on 'data', (newFile) ->
                should.exist(newFile)
                should.exist(newFile.path)
                should.exist(newFile.relative)
                should.exist(newFile.contents)
                newFile.path.should.equal './test/fixture/file.js'
                newFile.relative.should.equal 'file.js'
                ++dataCounter

            stream.on 'error', ->
                # prevent stream from throwing

            stream.once 'end', ->
                dataCounter.should.equal 0
                done()

            stream.write fakeFile
            stream.end()

        it 'emits error if `file.coffeelint.success===false`', (done) ->
            dataCounter = 0
            errorCounter = 0

            fakeFile = new gutil.File
                path: './test/fixture/file.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'success()'

            fakeFile.coffeelint = success: true

            fakeFile2 = new gutil.File
                path: './test/fixture/file2.js',
                cwd: './test/',
                base: './test/fixture/',
                contents: new Buffer 'yeahmetoo()'

            fakeFile2.coffeelint = success: false, results: [bugs: 'many']


            stream = coffeelint.reporter 'fail'

            stream.on 'data', (newFile) ->
                ++dataCounter

            stream.once 'end', ->
                dataCounter.should.equal 2
                stub.calledOnce.should.equal true
                (should stub.firstCall.args).eql ['file2.js', [bugs: 'many']]
                errorCounter.should.equal 1
                done()

            stream.on 'error', (e) ->
                ++errorCounter
                should.exist e
                e.should.have.property 'message'
                e.message.should.equal 'CoffeeLint failed for file2.js'

            stream.write fakeFile
            stream.write fakeFile2
            stream.write fakeFile
            stream.end()

