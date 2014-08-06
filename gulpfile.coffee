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
  # Livereload
  livereload.listen()
  gulp.watch("#{paths.sass.out}#{paths.sass.name}").on('change', livereload.changed)
  gulp.watch("#{paths.coffee.out}#{paths.coffee.name}").on('change', livereload.changed)
  gulp.watch("./partials/**/*.html").on('change', livereload.changed)
)

gulp.task('compile', ['browserify', 'lib', 'compass'])

gulp.task('lib', ->
  gulp.src(paths.lib.in)
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(coffee({bare: true}))
    .pipe(gulp.dest(paths.lib.out))
    .pipe(notify('Coffee script lib compile'))
)

gulp.task('coffee', ->
  gulp.src(paths.coffee.in)
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(replace(/^\s*((export|import|module) .*)\s*$/gm, '\n___es6("""$1""")'))
    .pipe(coffee({bare: true}))
    .pipe(replace(/^___es6\(\"(.*)\"\)\;$/gm, "$1;"))
    .pipe(gulp.dest('./tmp/'))
)

gulp.task('browserify', ['coffee'], ->
  gulp.src(paths.coffee.start)
    .pipe(plumber(notify.onError('<%=error.message%>')))
    .pipe(browserify({
      transform: [
        'traceurify'
      ]
    }))
    .pipe(rename(paths.coffee.name))
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
