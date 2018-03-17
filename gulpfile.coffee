_ = require 'gulp'
plugins = require('gulp-load-plugins')()
browserSync = require('browser-sync').create()
{ forEachObjIndexed } = require 'ramda'

#
# ──────────────────────────────────────────────────────────────────────────────── I ──────────
#   :::::: E R R O R   H A N D L E   M O D U L E S : :  :   :    :     :        :          :
# ──────────────────────────────────────────────────────────────────────────────────────────
#
combiner = require 'stream-combiner2'
chalk = require 'chalk'

errorWarp = combiner.obj

installErrorForCombined = (combined, name) -> 
  combined.on 'error', (error) -> 
      console.log(chalk.red name, 'has some error !\n')
      console.log(error.stack)
  combined

paths = 
  styles:
    src: ['src/styles/**/*.sass', '!src/styles/**/_*.sass']
    dest: 'assets/styles'
  scripts:
    src: 'src/scripts/**/*.coffee'
    dest: 'assets/scripts'
  views:
    src: ['src/views/**/*.pug', '!src/views/**/_*.pug'],
    dest: 'assets/views'

pug = () ->
  await return installErrorForCombined(errorWarp([
    _.src(paths.views.src),
    plugins.pug(),
    _.dest paths.views.dest
  ]), 'pug')

sass = () -> 
  _.src(paths.styles.src, { sourcemaps: true })
    .pipe(plugins.sass().on('error', plugins.sass.logError))
    .pipe _.dest paths.styles.dest
  await return

coffee = () ->
  await return installErrorForCombined(errorWarp([ 
    _.src(paths.scripts.src, { sourcemaps: true }),
    plugins.coffee({
      bare: true, 
      transpile: 
        presets: ['env'], 
        plugins: ['babel-plugin-syntax-async-functions'] 
    }),
    _.dest paths.scripts.dest
  ]), 'coffee')


tasks = 
  'styles': sass,
  'views': pug,
  'scripts': coffee

setUpWatch = forEachObjIndexed ({ src }, key) => _.watch src, tasks[key]

serve = () ->
  browserSync.init { server: './assets' }
  setUpWatch paths
  _.watch 'assets/**/*'
    .on 'change', browserSync.reload
  await return

_.task 'serve', _.series(sass, pug, coffee, serve)
