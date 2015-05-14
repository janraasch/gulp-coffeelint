<a name"0.5.0"></a>
## 0.5.0 (2015-05-14)


#### Features

* **custom-reporters:** allow external and custom Reporters ([c14be0f9](https://github.com/janraasch/gulp-coffeelint/commit/c14be0f9))
* **reporter-publish:** use Reporter.publish instead of .reporter ([4b3231f9](https://github.com/janraasch/gulp-coffeelint/commit/4b3231f9))


#### Breaking Changes

* **results:** the `results`-key now holds an instance of `Coffeelint::ErrorReport` (see https://github.com/clutchski/coffeelint/blob/master/src/error_report.coffee) instead of an `Array`. You may call `results.getErrors(filename)` to get the old `Array` back
* **reporter:** running `coffeelint.reporter('default')` now uses the *default* CoffeeLint reporter instead of the `coffeelint-stylish` reporter. You may run `coffeelint.reporter()` or `coffeelint.reporter('coffeelint-stylish')` to use the *stylish* reporter


## 0.4.0 (2014-09-01)


#### Features

* **fail-reporter-api:** 'fail'-reporter no longer fails on mere warnings, but 'failOnWarning' does ([b30c0e4c](https://github.com/janraasch/gulp-coffeelint/commit/b30c0e4ce686634c1110616fb268a081e8dbb853))
* **reporter:** nicer output for 'fail'-reporter ([02fe47a7](https://github.com/janraasch/gulp-coffeelint/commit/02fe47a7c20f891d43638cc44102bfccbebe47d8))


#### Breaking Changes

* Set `file.success` to `true` and fail `fail`-reporter only when `file.errorCount`
is 0, even if `files.warningCount > 0`. To achieve the previous behavior of the `fail`-reporter you
may use the `failOnWarning`-reporter.

 ([b30c0e4c](https://github.com/janraasch/gulp-coffeelint/commit/b30c0e4ce686634c1110616fb268a081e8dbb853))


### 0.3.4 (2014-08-23)


#### Maintenance

* update dependencies

### 0.3.3  (2014-05-17)


#### Maintenance

* update dependencies

### 0.3.2 (2014-03-31)


#### Bug Fixes

* **watch:** init params per call ([d560fd06](https://github.com/janraasch/gulp-coffeelint/commit/d560fd060707acfb296abd27658ddeb8864bf00d), closes [#12](https://github.com/janraasch/gulp-coffeelint/issues/12))


### 0.3.1 (2014-02-26)


#### Bug Fixes

* **dependencies:** fix #10 ([8340a4be](https://github.com/janraasch/gulp-coffeelint/commit/8340a4be7e73ab00dbc1daac5159d9da85736bbe))


## 0.3.0 (2014-02-25)


#### Features

* **reporter:** add `'fail'` reporter ([34fb6afb](https://github.com/janraasch/gulp-coffeelint/commit/34fb6afbdb41679b0fe5983f1bf89760a0179193))


### 0.2.2 (2014-02-17)


#### Maintenance
* use `^` instead of `~` in `package.json`, see [node-semver](https://github.com/isaacs/node-semver)

### 0.2.1 (2014-02-09)


#### Maintenance

* update dependencies

## 0.2.0 (2014-01-24)


#### Features

* **api:** simplify api, add `optFile` param and make all params optional ([28b74fbc](https://github.com/janraasch/gulp-coffeelint/commit/28b74fbc88aaf8cb1949cfd68b263755956dd3cf))
* **literate:** add default auto-detection for Literate CoffeeScript on `.litcoffee` and `.coffee.md` files ([80d55a73](https://github.com/janraasch/gulp-coffeelint/commit/80d55a73120b3d054262368c26012ffdf658695d))
