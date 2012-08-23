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
  server.use (require "connect-assets") src: "static"
  server.use connect.static __dirname + "/static"
  server.set "view options",
    layout: false
    pretty: process.env.NODE_ENV != "production"


  server.use connect.logger ":date | :remote-addr | :method (:referrer) -> (:url)"
  server.use express.cookieParser()
  server.use express.bodyParser()
  server.use express.session secret: "gamma"

  server.use server.router
  null

sessionDefaultKeys = ["cookie","lastAccess","touch","resetLastAccess","resetMaxAge","save","reload","destroy","regenerate"]
withSessionLocals = (req, vars={}) ->
    for k,v of req.session
        if k not in sessionDefaultKeys
            vars[k] = v
    vars

# Routes
server.get '/', (req, res) ->
  fs.readFile "views/md/index.markdown", "utf8", (e, content) ->
    throw e if e
    res.render '', withSessionLocals req,
        title: ''
        content: markdown content

server.post "/_set_session_vars", (req, res) ->
    req.session[k] = v for k,v of req.body
    req.session.save()
    res.end()

server.get /^\/canvas\/([\w-]+\/?)+$/, (req, res) ->
  canvasScript = stripSlashes(req.params[0])
    .split('/')
    .reverse()[0]

  try
    fs.lstatSync "static/js/canvas/#{canvasScript}"
    res.render "canvas/canvas", withSessionLocals req,
      canvasScript: canvasScript
      title: canvasScript
  catch e
    res.render "404", withSessionLocals req

server.get /^\/([\/\w-]+)$/, (req, res) ->
  path = req.params[0].replace /(^\/?|\/?$)/g, ""
  fs.readFile "views/md/#{path}.markdown", "utf8", (e, content) ->
    if e then res.render "404", withSessionLocals req
    else res.render path, withSessionLocals req,
      title: path
      content: markdown content

server.get "/500", (req, res) ->
  throw new Error "This is a 500 error."

server.get "/*", (req, res) ->
  throw new NotFound

# Error Handling
server.error (err, req, res, next) ->
  if err instanceof NotFound
    res.render "404", withSessionLocals req,
        title: "404 - Not Found"
        status: 404
  else
    res.render "500", withSessionLocals req,
        title : "The Server Encountered an Error"
        error: err
        status: 500

NotFound = (msg) ->
  this.name = 'NotFound'
  Error.call this, msg
  Error.captureStackTrace this, arguments.callee

stripSlashes = (ss) ->
  ss.replace(/^\/+/g, '').replace(/\/+$/g, '')


server.listen  port
console.log "Listening on http://0.0.0.0:" + port
