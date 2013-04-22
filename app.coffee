http    = require 'http'
express = require 'express'

_ = require 'underscore'

app = express()
server = http.createServer(app)
io = require('socket.io').listen(server)
geoip = require('geoip-lite')

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
  ip = req.param "ip", null
  data = req.param "data", {}
  lat = req.param "lat", null
  lng = req.param "lng", null
  geo = geoip.lookup(ip)
  if geo
    data.ll = geo.ll
  else if lat and lng
    data.ll = [lat, lng]
  else
    res.send(500, {status: 'ip parameter missing or invalid'})
    return

  dests = []
  dest_from_conn = (conn) ->
    for dest in dests
      return dest if dest.conn == conn
    return null

  for label in labels
    conns = dispatcher.get(label)
    for conn in conns
      dest = dest_from_conn(conn)
      if not dest
        dests.push({'conn': conn, 'labels': [label]})
      else
        dest.labels.push(label)

  for dest in dests
    dest.conn.emit('data', _.extend({}, data, {labels: dest.labels}))

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

  socket.on('deregister', (labels) ->
    for label in labels
      dispatcher.remove(label, socket)
  )

  socket.on('disconnect', ->
    for label in label_cache
      dispatcher.remove(label, socket)
  )
)

server.listen(3000)
console.log "LISNIN' ON THE OL' 3000"
