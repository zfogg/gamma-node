# Dependencies
connect  = require "connect"
express  = require "express"
fs       = require "fs"
markdown = (require "markdown").markdown.toHTML

# Config
server = express.createServer()
port   = process.env.PORT or 8081
server.configure ->
    server.set "views", __dirname + "/views"
    server.use connect.static __dirname + "/static"
    server.use connect.bodyParser()
    server.use express.cookieParser()
    server.use express.session secret: "shhhhh!"
    server.use server.router
    null

# Routes
server.get "/", (req, res) ->
  fs.readFile 'views/md/index.markdown', 'utf8', (e, content) ->
    throw e if e
    res.render "index.jade",
      locals:
          title: "Page Title",
          description: "Description of site.",
          author: ""
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
