express = require 'express'

app = express()

class Dispatcher
  constructor: (@dmap = {}) ->

  add: (label, conn) ->
    if not @dmap[label]
      @dmap[label] = [conn]
    else
      @dmap[label].push(conn)

  get: (label) ->
    return @dmap[label] or []

dispatcher = new Dispatcher()

app.all('/in', (req, res)->
  labels = req.param "labels", []
  dests = []
  dests_contains = (conn) ->
    for dest in dests
      return true if dest == conn
    return false

  for label in labels
    conns = dispatcher.get(label)
    console.dir conns
    for conn in conns
      if not dests_contains(conn)
        dests.push(conn)

  for dest in dests
    null
    # dest.emit(req.params "obj")
  res.json({dest: dests})
)

app.all('/register', (req, res)->
  labels = req.param "labels", []
  for label in labels
    conn = {}
    dispatcher.add(label, label)

  res.json({})
)

app.listen(3000)
console.log "LISNIN' ON THE OL' 3000"
