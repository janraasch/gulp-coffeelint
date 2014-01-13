# module dependencies
gutil = require 'gulp-util'
should = require 'should'
sinon = require 'sinon'

# SUT
coffeelint = require '../'

# globals
reporter_module = require 'coffeelint-stylish'
stub = null

describe 'gulp-coffeelint', ->
    describe 'coffeelint.reporter()', ->
        beforeEach ->
            # reset statistics
            countReporterCalls = 0
            countFileNames = []
            countResults = []

            stub = sinon.stub reporter_module, 'reporter', ->
                'I am a mocking bird'
        afterEach ->
            reporter_module.reporter.restore()

        it 'should pass through the file', (done) ->
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

        it 'only calls reporter if file.coffeelint.success=false', (done) ->
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
