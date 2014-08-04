gulp       = require('gulp')
sync       = require('gulp-sync')(gulp).sync
notify     = require('gulp-notify')
plumber    = require('gulp-plumber')
livereload = require('gulp-livereload')
compass    = require('gulp-compass')
nodemon    = require('gulp-nodemon')
coffee     = require('gulp-coffee')
replace    = require('gulp-replace')
browserify = require('gulp-browserify')
rename     = require('gulp-rename')

paths = {
  sass:
    in:   './static/sass/**/*.sass'
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
  gulp.watch(paths.coffee.in, ['compile:src'])
  gulp.watch(paths.lib.in, ['coffee:lib'])
  gulp.watch(paths.sass.in, ['compass'])
  # Livereload
  livereload.listen()
  gulp.watch("#{paths.sass.out}#{paths.sass.name}").on('change', livereload.changed)
  gulp.watch("#{paths.coffee.out}#{paths.coffee.name}").on('change', livereload.changed)
  gulp.watch("./partials/**/*.html").on('change', livereload.changed)
)

gulp.task('compile', ['src', 'coffee-lib', 'compass'])
gulp.task('src', sync(['coffee-src', 'browserify']))

gulp.task('coffee-lib', ->
  gulp.src(paths.lib.in)
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.lib.out))
    .pipe(notify('Coffee script lib compile'))
)

gulp.task('coffee-src', ->
  gulp.src(paths.coffee.in)
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(replace(/^\s*(import.*)\s*$/gm, '___es6("""$1""")'))
    .pipe(replace(/^\s*(export.*)\s*$/gm, '___es6("""$1""")'))
    .pipe(coffee({bare: true}))
    .pipe(replace(/^___es6\(\"(.*)\"\)\;$/gm, "$1;"))
    .pipe(gulp.dest('./tmp/'))
)

gulp.task('browserify', ->
  gulp.src('src/js/app.js')
    .pipe(browserify({
      debug: true
      transform: [
        'debowerify'
        'traceurify'
        'aliasify'
      ]
    }))
    .pipe(gulp.dest('./build/js'))
    .transform(traceurify({ module: 'commonjs' }))
    .bundle()
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(source(paths.coffee.name))
    .pipe(gulp.dest(paths.coffee.out))
    .pipe(notify('Browerify Done'))
)

gulp.task('compass', ->
  gulp.src(paths.sass.in)
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(compass({
      style:      'compressed'
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
  nodemon({
    script: 'server.coffee'
    quiet: true
  })
)
