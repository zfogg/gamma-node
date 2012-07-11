# Dependencies
connect  = require "connect"
express  = require "express"
fs       = require "fs"
markdown = (require "markdown").markdown.toHTML

# Config
server = express.createServer()
port   = process.env.PORT or 8000
server.configure ->
  server.set "views", __dirname + "/views"
  server.set "view engine", "jade"
  server.set 'view options', layout: false, pretty: true
  server.use (require "connect-assets") src: "static"
  server.use connect.static __dirname + "/static"
  server.use connect.bodyParser()
  server.use express.cookieParser()
  server.use express.session secret: "gamma"
  server.use server.router

  null

# Routes
server.get "/", (req, res) ->
  fs.readFile 'views/md/index.markdown', 'utf8', (e, content) ->
    throw e if e
    res.render '',
      locals:
        title: ''
        content: markdown content

server.get /^\/canvas\/?$/, (req, res) ->
  res.render "canvas"
    title: ''

server.get /^\/canvas\/([\w-]+\/?)+/, (req, res) ->
  name = req.params[0].split('/').reverse()[0]
  res.render "canvas/canvas",
    canvasScript: name
    title: name

server.get /^\/((\/?[\w-]+)*)/, (req, res) ->
  fs.readFile "views/md/#{req.params[0]}.markdown", 'utf8', (e, content) ->
    if e then res.render "404"
    else
      res.render req.params[0],
        title: req.params[0]
        content: markdown content

server.get "/500", (req, res) ->
  throw new Error "This is a 500 error."

server.get "/*", (req, res) ->
  throw new NotFound

# Error Handling
server.error (err, req, res, next) ->
  if err instanceof NotFound
    res.render "404",
      locals:
        title: "404 - Not Found"
      status: 404
  else
    res.render "500"
      locals:
        title : "The Server Encountered an Error"
        error: err
      status: 500

NotFound = (msg) ->
  this.name = 'NotFound'
  Error.call this, msg
  Error.captureStackTrace this, arguments.callee

server.listen  port
console.log "Listening on http://0.0.0.0:" + port
