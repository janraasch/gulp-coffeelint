# gulp-coffeelint [![Build Status][travis-image]][travis-url] [![Coverage Status][coveralls-image]][coveralls-url] [![NPM version][npm-image]][npm-url]
[![Dependency Status][depstat-image]][depstat-url] [![devDependency Status][devdepstat-image]][devdepstat-url]

> [CoffeeLint](http://www.coffeelint.org/) plugin for [gulp][gulp] 3.

## Usage

First, install `gulp-coffeelint` as a development dependency:

```shell
npm install --save-dev gulp-coffeelint
```

Then, add it to your `gulpfile.js`:

```javascript
var gulp = require('gulp');
var coffeelint = require('gulp-coffeelint');

gulp.task('lint', function () {
    gulp.src('./src/*.coffee')
        .pipe(coffeelint())
        .pipe(coffeelint.reporter())
});
```

## API

### `coffeelint([optFile,] [opt,] [literate,] [rules])`
All arguments are optional. By default `gulp-coffeelint` will walk up the directory tree looking for a `coffeelint.json` (per file, i.e. dirname) or a `package.json` that has a `coffeelintConfig` object ([as the cli does](http://www.coffeelint.org/#usage)). Also, `.litcoffee` and `.coffee.md` files will be treated as Literate CoffeeScript.

### optFile
Type: `String`

Absolute path of a `json` file containing [options][coffeelint-options] for `coffeelint`.

### opt
Type: `Object`

[Options][coffeelint-options] you wish to send to `coffeelint`. If `optFile` is given, this will be ignored.

### literate
Type: `Boolean`

Are we dealing with Literate CoffeeScript?

### rules
Type: `Array[Function]`
Default: `[]`

Add [custom rules](http://www.coffeelint.org/#api) to `coffeelint`.

## Results

Adds the following properties to the `file` object:
```javascript
file.coffeelint.success = true; // or false
file.coffeelint.errorCount = 0; // number of errors returned by `coffeelint`
file.coffeelint.warningCount = 0; // number of warnings returned by `coffeelint`
file.coffeelint.results = []; // `coffeelint` results, see http://www.coffeelint.org/#api
file.coffeelint.opt = {}; // the options use by `coffeelint`
file.coffeelint.literate = false; // you guessed it
```

## Reporters

### `coffeelint.reporter(name)`
Assuming you would like to make use of those pretty results we have after piping through `coffeelint()` there are some bundled reporters at your service.

### name
Type: `String`
Default: `'default'`
Possible Values: `'default'`, `'fail'`

The `'default'` reporter uses [coffeelint-stylish](https://npmjs.org/package/coffeelint-stylish) to output a pretty report, while the `'fail'` reporter causes the stream to emit an `error`, if `file.coffeelint.success === false`.

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [gulp][gulp] and [npm-test](https://npmjs.org/doc/test.html). Plus, make sure to adhere to these [commit message conventions](https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#heading=h.uyo6cb12dt6w).

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License) © [Jan Raasch](http://janraasch.com)

[gulp]: http://gulpjs.com/
[coffeelint-options]: http://www.coffeelint.org/#options

[npm-url]: https://npmjs.org/package/gulp-coffeelint
[npm-image]: https://badge.fury.io/js/gulp-coffeelint.png

[travis-url]: http://travis-ci.org/janraasch/gulp-coffeelint
[travis-image]: https://secure.travis-ci.org/janraasch/gulp-coffeelint.png?branch=master

[coveralls-url]: https://coveralls.io/r/janraasch/gulp-coffeelint
[coveralls-image]: https://coveralls.io/repos/janraasch/gulp-coffeelint/badge.png

[depstat-url]: https://david-dm.org/janraasch/gulp-coffeelint
[depstat-image]: https://david-dm.org/janraasch/gulp-coffeelint.png

[devdepstat-url]: https://david-dm.org/janraasch/gulp-coffeelint#info=devDependencies
[devdepstat-image]: https://david-dm.org/janraasch/gulp-coffeelint/dev-status.png
