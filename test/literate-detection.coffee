'use strict'

# module dependencies
should = require 'should'
gutil = require 'gulp-util'
path = require 'path'

# SUT
coffeelint = require '../'

describe 'gulp-coffeelint', ->
    describe 'coffeelint()', ->
        describe 'should detect (non-Literate) CoffeeScript', ->
            it 'on .coffee with Literate contents', (done) ->
                dataCounter = 0

                fakeFile = new gutil.File
                    path: './test/fixture/file.coffee',
                    cwd: './test/',
                    base: './test/fixture/',
                    contents: new Buffer 'Comments!\n  yeah()'

                stream = coffeelint {}

                stream.on 'data', (newFile) ->
                    ++dataCounter
                    should.exist(newFile.coffeelint.success)
                    should.exist(newFile.coffeelint.literate)
                    newFile.coffeelint.success.should.be.false
                    newFile.coffeelint.literate.should.be.false

                stream.once 'end', ->
                    dataCounter.should.equal 1
                    done()

                stream.write fakeFile
                stream.end()

            it 'on .litcoffee with literate: false', (done) ->
                dataCounter = 0

                fakeFile = new gutil.File
                    path: './test/fixture/file.litcoffee',
                    cwd: './test/',
                    base: './test/fixture/',
                    contents: new Buffer 'Comments!\n  yeah()'

                stream = coffeelint false

                stream.on 'data', (newFile) ->
                    ++dataCounter
                    should.exist(newFile.coffeelint.success)
                    should.exist(newFile.coffeelint.literate)
                    newFile.coffeelint.success.should.be.false
                    newFile.coffeelint.literate.should.be.false

                stream.once 'end', ->
                    dataCounter.should.equal 1
                    done()

                stream.write fakeFile
                stream.end()

            for extension in ['.coffee', '.js', '.custom', '.md', '.', '']
                ((extension) ->
                    it "on #{(extension or 'no extension')}", (done) ->
                        dataCounter = 0

                        fakeFile = new gutil.File
                            path: "./test/fixture/file' #{extension}",
                            cwd: './test/',
                            base: './test/fixture/',
                            contents: new Buffer 'yeah()'

                        stream = coffeelint {}

                        stream.on 'data', (newFile) ->
                            ++dataCounter
                            should.exist(newFile.coffeelint.success)
                            should.exist(newFile.coffeelint.literate)
                            newFile.coffeelint.success.should.be.true
                            newFile.coffeelint.literate.should.be.false

                        stream.once 'end', ->
                            dataCounter.should.equal 1
                            done()

                        stream.write fakeFile
                        stream.end()
                )(extension)

        describe 'should detect Literate CoffeeScript', ->
            for extension in ['.litcoffee', '.coffee.md']
                ((extension) ->
                    it 'on ' + extension, (done) ->
                        dataCounter = 0

                        fakeFile = new gutil.File
                            path: './test/fixture/file' + extension,
                            cwd: './test/',
                            base: './test/fixture/',
                            contents: new Buffer 'Comments!\n  yeah()'

                        stream = coffeelint {}

                        stream.on 'data', (newFile) ->
                            ++dataCounter
                            should.exist(newFile.coffeelint.success)
                            should.exist(newFile.coffeelint.literate)
                            newFile.coffeelint.success.should.be.true
                            newFile.coffeelint.literate.should.be.true

                        stream.once 'end', ->
                            dataCounter.should.equal 1
                            done()

                        stream.write fakeFile
                        stream.end()
                )(extension)

            it 'on .coffee with literate: true', (done) ->
                dataCounter = 0

                fakeFile = new gutil.File
                    path: './test/fixture/file.coffee',
                    cwd: './test/',
                    base: './test/fixture/',
                    contents: new Buffer 'yeah()'

                stream = coffeelint true

                stream.on 'data', (newFile) ->
                    ++dataCounter
                    should.exist(newFile.coffeelint.success)
                    should.exist(newFile.coffeelint.literate)
                    newFile.coffeelint.success.should.be.false
                    newFile.coffeelint.literate.should.be.true

                stream.once 'end', ->
                    dataCounter.should.equal 1
                    done()

                stream.write fakeFile
                stream.end()

        describe 'for multiple files', ->
            it 'should detect CS and LCS in single stream', (done) ->
                dataCounter = 0

                extensions =
                    '.coffee': false,
                    '.litcoffee': true,
                    '.js': false,
                    '.coffee.md': true,
                    '.md': false

                fakeFiles = for extension, literate of extensions
                    fakeFile = new gutil.File
                        path: './test/fixture/file' + extension,
                        cwd: './test/',
                        base: './test/fixture/',
                        contents: new Buffer 'yeah()'
                    fakeFile.literate = literate
                    fakeFile

                stream = coffeelint {}

                stream.on 'data', (newFile) ->
                    should.exist(newFile.coffeelint.success)
                    should.exist(newFile.coffeelint.literate)
                    newFile.coffeelint.literate.should.equal(
                        newFile.literate)
                    ++dataCounter

                stream.once 'end', ->
                    dataCounter.should.equal 5
                    done()

                stream.write fakeFile for fakeFile in fakeFiles
                stream.end()

            it 'should treat all as Literate when literate: true', (done) ->
                dataCounter = 0

                extensions = [
                    '.coffee'
                    '.litcoffee'
                    '.js'
                    '.coffee.md'
                    '.md'
                ]

                fakeFiles = for extension in extensions
                    fakeFile = new gutil.File
                        path: './test/fixture/file' + extension,
                        cwd: './test/',
                        base: './test/fixture/',
                        contents: new Buffer 'yeah()'

                stream = coffeelint {}, true

                stream.on 'data', (newFile) ->
                    should.exist(newFile.coffeelint.success)
                    should.exist(newFile.coffeelint.literate)
                    newFile.coffeelint.literate.should.be.true
                    ++dataCounter

                stream.once 'end', ->
                    dataCounter.should.equal 5
                    done()

                stream.write fakeFile for fakeFile in fakeFiles
                stream.end()

            it 'should treat all as non-Lit when literate: false', (done) ->
                dataCounter = 0

                extensions = [
                    '.coffee'
                    '.litcoffee'
                    '.js'
                    '.coffee.md'
                    '.md'
                ]

                fakeFiles = for extension in extensions
                    fakeFile = new gutil.File
                        path: './test/fixture/file' + extension,
                        cwd: './test/',
                        base: './test/fixture/',
                        contents: new Buffer 'yeah()'

                stream = coffeelint {}, false

                stream.on 'data', (newFile) ->
                    should.exist(newFile.coffeelint.success)
                    should.exist(newFile.coffeelint.literate)
                    newFile.coffeelint.literate.should.be.false
                    ++dataCounter

                stream.once 'end', ->
                    dataCounter.should.equal 5
                    done()

                stream.write fakeFile for fakeFile in fakeFiles
                stream.end()
