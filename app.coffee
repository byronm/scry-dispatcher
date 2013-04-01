http    = require 'http'
express = require 'express'

app = express()
server = http.createServer(app)
io = require('socket.io').listen(server)

class Dispatcher
  constructor: (@connections = {}) ->

  add: (label, conn) ->
    if not @connections[label]
      @connections[label] = [conn]
    else
      @connections[label].push(conn)

  get: (label) ->
    return @connections[label] or []

  remove: (label, conn) ->
    @connections[label] = @connections[label].filter((elem) -> return elem != conn)

dispatcher = new Dispatcher()

################################################################################
# HTTP Endpoints
################################################################################
app.all('/in', (req, res)->
  labels = req.param "labels", []
  dests = []
  dests_contains = (conn) ->
    for dest in dests
      return true if dest == conn
    return false

  for label in labels
    conns = dispatcher.get(label)
    for conn in conns
      if not dests_contains(conn)
        dests.push(conn)

  for dest in dests
    dest.emit('data', req.param "data")

  res.json({status: 'ok'})
)

################################################################################
# Websockets Endpoints
################################################################################
io.sockets.on('connection', (socket) ->
  label_cache = []
  socket.on('register', (labels) ->
    label_cache = label_cache.concat(labels)
    console.dir label_cache
    for label in labels
      dispatcher.add(label, socket)
  )
  socket.on('disconnect', ->
    for label in label_cache
      dispatcher.remove(label, socket)
  )
)

server.listen(3000)
console.log "LISNIN' ON THE OL' 3000"
