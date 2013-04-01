http    = require 'http'
express = require 'express'
io      = require 'socket.io'

app = express()
server = http.createServer(app)
io.listen(server)

class Dispatcher
  constructor: (@dmap = {}) ->

  add: (label, conn) ->
    if not @dmap[label]
      @dmap[label] = [conn]
    else
      @dmap[label].push(conn)

  get: (label) ->
    return @dmap[label] or []

  remove: (label, conn) ->
    @dmap[label] = @dmap[label].filter((elem) -> return elem != conn)

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
    dest.emit('data', req.params "data")

  res.json({status: 'ok'})
)

################################################################################
# Websockets Endpoints
################################################################################
io.sockets.on('connection', (socket) ->
  label_cache = []
  socket.on('register', (labels) ->
    label_cache = label_cache.concat(labels)
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
