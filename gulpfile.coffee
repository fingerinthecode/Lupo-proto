exec       = require('child_process').exec
args       = require('yargs').argv
gulp       = require('gulp')
sync       = require('gulp-sync')(gulp).sync
gulpif     = require('gulp-if')
notify     = require('gulp-notify')
plumber    = require('gulp-plumber')
livereload = require('gulp-livereload')
compass    = require('gulp-compass')
coffee     = require('gulp-coffee')
replace    = require('gulp-replace')
browserify = require('gulp-browserify')
rename     = require('gulp-rename')
karma      = require('karma').server
uglify     = require('gulp-uglify')
sourcemaps = require('gulp-sourcemaps')

database   = args.db ? 'default'
production = args.prod ? false
watchMode  = false

# CommonJS to Requirejs
# Also prevent error from coffeescript
cjs2rjs = (result)->
  match = /(?:'|")(.*)(?:'|")/.exec(result)
  if match?
    filepath = match[1]
    filename = filepath.split('/')[-1..-1][0]
    ext      = filename.split('.')[-1..-1][0]
    if filepath[-1..-1][0] == '/' # Directory
      result = result.replace(filepath, "#{filepath}index.js")
    else if ext == 'coffee'   # Wrong extension
      result = result.replace(filename, filename.replace('.coffee', '.js'))
    else if ext == filename # No extension
      result = result.replace(filepath, "#{filepath}.js")

  return "___es6(\"#{result}\")"

paths = {
  sass:
    in:   './static/sass/style.sass'
    out:  './static/css/'
    name: 'style.css'
  lib:
    in:    './static/coffee/*.coffee'
    out:   './static/js/'
  coffee:
    start: './tmp/src/Main/index.js'
    in:    'src/**/*.coffee'
    out:   './static/js/'
    name:  'main.js'
  unit:
    in:    './test/unit/**/*.coffee'
    out:   './tmp/unit/'
}

gulp.task('default', ->
  # Server
  gulp.start('server')
  # Auto Compile
  gulp.watch(paths.coffee.in, ['browserify'])
  gulp.watch(paths.unit.in, ['coffee-test'])
  gulp.watch(paths.lib.in, ['lib'])
  gulp.watch(paths.sass.in, ['compass'])
  # test
  watchMode = true
  gulp.start('test')
  # Livereload
  livereload = livereload()
  gulp.watch([
    "#{paths.sass.out}#{paths.sass.name}"
    "#{paths.coffee.out}#{paths.coffee.name}"
    "./partials/**/*.html"
  ]).on('change', (file)->
    livereload.changed(file.path)
  )
)

gulp.task('compile', ['browserify', 'lib', 'compass'])
gulp.task('init', sync(['kanso-delete', 'kanso-create', 'kanso-push', 'kanso-upload']))

gulp.task('kanso-delete', (done)->
  exec("kanso deletedb #{database}", done)
)
gulp.task('kanso-create', (done)->
  exec("kanso createdb #{database}", done)
)
gulp.task('kanso-push', (done)->
  exec("kanso push #{database}", done)
)
gulp.task('kanso-upload', (done)->
  exec("kanso upload ./data #{database}", done)
)

gulp.task('lib', ->
  gulp.src(paths.lib.in)
    .pipe(plumber(notify.onError('<%=error.stack%>')))
    .pipe(replace(/^ *((export|import|module) *.*) *$/gm, cjs2rjs))
    .pipe(gulpif(not production, sourcemaps.init()))
    .pipe(coffee({bare: true}))
    .pipe(gulpif(not production, sourcemaps.write()))
    .pipe(replace(/^___es6\(\"(.*)\"\)\;$/gm, "$1;"))
    .pipe(gulp.dest(paths.lib.out))
    .pipe(notify('Coffee script lib compile'))
)

gulp.task('coffee-test', ->
  gulp.src(paths.unit.in)
    .pipe(plumber(notify.onError('<%=error.stack%>')))
    .pipe(replace(/^ *((export|import|module) *.*) *$/gm, cjs2rjs))
    .pipe(gulpif(not production, sourcemaps.init()))
    .pipe(coffee({bare: true}))
    .pipe(gulpif(not production, sourcemaps.write()))
    .pipe(replace(/^___es6\(\"(.*)\"\)\;$/gm, "$1;"))
    .pipe(gulp.dest(paths.unit.out))
)

gulp.task('coffee', ->
  gulp.src(paths.coffee.in)
    .pipe(plumber(notify.onError('<%=error.stack%>')))
    .pipe(replace(/^ *((export|import|module) *.*) *$/gm, cjs2rjs))
    .pipe(gulpif(not production, sourcemaps.init()))
    .pipe(coffee({bare: true}))
    .pipe(gulpif(not production, sourcemaps.write()))
    .pipe(replace(/^___es6\(\"(.*)\"\)\;$/gm, "$1;"))
    .pipe(gulp.dest('./tmp/src/'))
)

gulp.task('browserify', ['coffee'], ->
  shim = require('./package.json').shim ? {}

  gulp.src(paths.coffee.start, {read: false})
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(browserify({
      insertGlobals: not production
      debug: not production
      shim: shim
      transform: [
        'traceurify'
      ]
    }))
    .pipe(rename(paths.coffee.name))
    .pipe(gulpif(production, uglify()))
    .pipe(gulp.dest(paths.coffee.out))
    .pipe(notify('Browerify Done'))
)

gulp.task('test', ['coffee-test'], (done)->
  config = {config: {}, set: (config)-> @conf = config}
  require('./test/karma.conf.coffee')(config)
  if not watchMode
    config.conf.watch = false
    config.conf.singleRun = true
  karma.start(config.conf, done)
)

gulp.task('compass', ->
  gulp.src(paths.sass.in)
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(compass({
      style:      (if production then 'compressed' else 'expanded')
      comments:   false
      relative:   true
      project:    './'
      css:        './static/css/'
      sass:       './static/sass/'
      javascript: './static/js/'
      font:       'static/fonts/'
      require:    []
    }))
    .pipe(gulp.dest(paths.sass.out))
    .pipe(notify('Compass compiled without errors'))
)

gulp.task('server', (done)->
  exec("node ./node_modules/coffee-script/bin/coffee ./server.coffee", done)
)
