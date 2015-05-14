# gulp-coffeelint [![Build Status][travis-image]][travis-url] [![Coverage Status][coveralls-image]][coveralls-url] [![NPM version][npm-image]][npm-url]
[![Dependency Status][depstat-image]][depstat-url] [![devDependency Status][devdepstat-image]][devdepstat-url] ![Pretty Stylish](http://img.shields.io/badge/pretty-stylish-ff69b4.svg)

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
file.coffeelint.success = true; // if no errors were found, false otherwise
file.coffeelint.errorCount = 0; // number of errors returned by `coffeelint`
file.coffeelint.warningCount = 0; // number of warnings returned by `coffeelint`
file.coffeelint.results = ErrorReport Object; // instance of `Coffeelint::ErrorReport` , see https://github.com/clutchski/coffeelint/blob/master/src/error_report.coffee
file.coffeelint.opt = {}; // the options used by `coffeelint`
file.coffeelint.literate = false; // you guessed it
```

## Reporters

### name
Type: `String`, `Function`
Default: `'coffeelint-stylish'`

### CoffeeLint reporters

#### Built-in

You can choose any [CoffeeLint reporter](https://github.com/clutchski/coffeelint/tree/master/src/reporters)
when you call

```js
stuff
  .pipe(coffeelint())
  .pipe(coffeelint.reporter('csv'))
```

#### External

Let's use [coffeelint-stylish](https://github.com/janraasch/coffeelint-stylish) as an example. External modules can be referenced either as
the reporter's constructor function or as its module name.

```js
var stylish = require('coffeelint-stylish');

gulp.src('./src/*.coffee')
  .pipe(coffeelint())
  .pipe(coffeelint.reporter(stylish))
```

-- OR --

```js
gulp.src('./src/*.coffee')
  .pipe(coffeelint())
  .pipe(coffeelint.reporter('coffelint-stylish'))
```

Any module following the CoffeeLint Reporter module format should work. These modules have a constructor accepting a `CoffeeLint::ErrorReport Object`, and provide a `publish` function.

### Fail and FailOnWarning Reporters

Do you want the task to fail when a CoffeeLint error or warning happens? gulp-coffeelint includes `fail` and `failOnWarning` reporters for this.

This example will log the errors using the stylish reporter, then fail if CoffeeLint was not a success.

```js
gulp.src('./src/*.coffee')
  .pipe(coffeelint())
  .pipe(coffeelint.reporter('coffeelint-stylish'))
  .pipe(coffeelint.reporter('fail'))
```

### Custom Reporters

Specify your own downstream Reporter for CoffeeLint results.

```js
var coffeelint = require('gulp-coffeelint');

var myReporter = (function() {
  function MyReporter(errorReport) {
    this.errorReport = errorReport;
  }

  MyReporter.prototype.publish = function() {
    var hasError = this.errorReport.hasError();
    if (hasError) {
      return console.log('Oh no!');
    }
    return console.log('Oh yeah!');
  }

  return MyReporter;
})();

gulp.task('lint', function() {
  return gulp.src('./src/*.coffee')
    .pipe(coffeelint())
    .pipe(coffeelint.reporter(myReporter));
});
```


## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [gulp][gulp] and [npm-test](https://npmjs.org/doc/test.html). Plus, make sure to adhere to these [commit message conventions](https://docs.google.com/document/d/1QrDFcIiPjSLDn3EL15IJygNPiHORgU1_OOAqWjiDU5Y/edit#heading=h.uyo6cb12dt6w).

## License

[MIT License](http://en.wikipedia.org/wiki/MIT_License) © [Jan Raasch](http://janraasch.com)

[gulp]: http://gulpjs.com/
[coffeelint-options]: http://www.coffeelint.org/#options

[npm-url]: https://npmjs.org/package/gulp-coffeelint
[npm-image]: http://img.shields.io/npm/v/gulp-coffeelint.svg

[travis-url]: http://travis-ci.org/janraasch/gulp-coffeelint
[travis-image]: https://travis-ci.org/janraasch/gulp-coffeelint.svg?branch=master

[coveralls-url]: https://coveralls.io/r/janraasch/gulp-coffeelint
[coveralls-image]: https://img.shields.io/coveralls/janraasch/gulp-coffeelint.svg

[depstat-url]: https://david-dm.org/janraasch/gulp-coffeelint
[depstat-image]: https://david-dm.org/janraasch/gulp-coffeelint.svg

[devdepstat-url]: https://david-dm.org/janraasch/gulp-coffeelint#info=devDependencies
[devdepstat-image]: https://david-dm.org/janraasch/gulp-coffeelint/dev-status.svg
