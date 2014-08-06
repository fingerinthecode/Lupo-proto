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

database   = args.db ? 'default'
production = args.prod ? false
shim       = require('./package.json').shim ? {}
watch      = false

paths = {
  sass:
    in:   './static/sass/style.sass'
    out:  './static/css/'
    name: 'style.css'
  lib:
    in:    './static/coffee/*.coffee'
    out:   './static/js/'
  coffee:
    start: './tmp/Main/index.js'
    in:    './src/**/*.coffee'
    out:   './static/js/'
    name:  'main.js'
}

gulp.task('default', ->
  # Server
  gulp.start('server')
  # Auto Compile
  gulp.watch(paths.coffee.in, ['browserify'])
  gulp.watch(paths.lib.in, ['lib'])
  gulp.watch(paths.sass.in, ['compass'])
  # test
  watch = true
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

gulp.task('kanso-delete', (cb)->
  exec("kanso deletedb #{database}", cb)
)
gulp.task('kanso-create', (cb)->
  exec("kanso createdb #{database}", cb)
)
gulp.task('kanso-push', (cb)->
  exec("kanso push #{database}", cb)
)
gulp.task('kanso-upload', (cb)->
  exec("kanso upload ./data #{database}", cb)
)

gulp.task('lib', ->
  gulp.src(paths.lib.in)
    .pipe(plumber(notify.onError('<%=error.stack%>')))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.lib.out))
    .pipe(notify('Coffee script lib compile'))
)

gulp.task('coffee', ->
  gulp.src(paths.coffee.in)
    .pipe(plumber(notify.onError('<%=error.stack%>')))
    .pipe(replace(/^\s*((export|import|module) .*)\s*$/gm, '\n___es6("""$1""")'))
    .pipe(coffee({bare: true}))
    .pipe(replace(/^___es6\(\"(.*)\"\)\;$/gm, "$1;"))
    .pipe(gulp.dest('./tmp/'))
)

gulp.task('browserify', ['coffee'], ->
  gulp.src(paths.coffee.start)
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(browserify({
      insertGlobals : not production
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

gulp.task('test', (done)->
  config = {config: {}, set: (config)-> @conf = config}
  require('./test/karma.conf.coffee')(config)
  if not watch
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
