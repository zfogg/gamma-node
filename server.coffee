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
    res.render "",
      locals:
        title: "ZF",
        description: "Zach Fogg's personal public-facing website.",
        author: "Zach Fogg"
        analyticssiteid: "XXXXXXX"
        content: markdown content

server.get "/500", (req, res) ->
    throw new Error "This is a 500 error."

server.get "/*", (req, res) ->
    throw new NotFound

# Error Handling
server.error (err, req, res, next) ->
  if err instanceof NotFound
    res.render "404.jade",
      locals:
        title: "404 - Not Found",
        description: "",
        author: "",
        analyticssiteid: "XXXXXXX",
      status: 404
  else
    res.render "500.jade",
      locals:
        title : "The Server Encountered an Error",
        description: "",
        author: "",
        analyticssiteid: "XXXXXXX",
        error: err,
      status: 500

NotFound = (msg) ->
    this.name = 'NotFound'
    Error.call this, msg
    Error.captureStackTrace this, arguments.callee

server.listen  port
console.log "Listening on http://0.0.0.0:" + port
