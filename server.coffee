http     = require('http')
fs       = require('fs')
path     = require('path')
port     = 80
proxy    = require('http-proxy').createProxyServer({
  target: "http://127.0.0.1:5984/"
})
rewrites = null
dbname   = null
p        = ".#{path.sep}src#{path.sep}Main#{path.sep}rewrites.js"

if fs.existsSync('./.kansorc')
  kanso  = require('./.kansorc')
  kanso  = kanso.env        ? {}
  kanso  = kanso.default    ? {}
  kanso  = kanso.db         ? ""
  if kanso != ""
    kanso  = kanso.split('/')
    dbname = kanso[-1..-1][0]

if dbname == null
  throw new Error('Impossible to find a .kansorc or to find a default configuration in it')

if fs.existsSync(p)
  rewrites = require(p.replace('\\', '/'))
  for rewrite in rewrites
    for m, i in rewrite.from.match(/(\:\w+|\*+)/gi) || []
      rewrite.to = rewrite.to.replace(m, "$#{i+1}")

    reg = "^#{rewrite.from}$".replace('/', '\\\/')
    reg = reg.replace('*', '(.*)')
    reg = reg.replace(/\:\w+/, '(\w+)')
    rewrite.from = new RegExp(reg, 'i')
else
  throw new Error('Impossible to find a rewrites.js in the directory :: ./src/Main/rewrites.js')

http.createServer( (req, res)->
  found   = null
  request = false
  for rewrite in rewrites
    match = rewrite.from.exec(req.url)
    if match
      found = rewrite.to
      for m in rewrite.to.match(/\$\d+/gi) || []
        num = parseInt(m.replace('$', ''))
        found = found.replace(m, match[num])
      break

  if found?
    link = "./#{found}"
  else if req.url.indexOf(dbname) != -1
    request = true
  else
    link = "./#{req.url}"

  # normalize link
  link = link.replace(/\/+/g, path.sep) if not request

  if request
    proxy.web(req, res)
  else if fs.existsSync(link)
    file = fs.readFileSync(link, {
      encoding: 'utf-8'
    })
    # Livereload
    if link.match(/.*index.html$/)
      localip = require('ip').address()
      file = file.replace('</body>', '<script src="http://'+localip+':35729/livereload.js?snipver=1"></script></body>')

    res.writeHead(200, {
      "Content-Length": file.length
      "Content-Encoding": 'utf-8'
    })
    res.end(file)
  else
    res.writeHead(404)
    res.end()

).listen(port)
