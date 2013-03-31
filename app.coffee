express = require 'express'

app = express()

class Dispatcher
  constructor: (@dmap = {}) ->

  add: (label, conn) ->
    if not @dmap[label]
      @dmap[label] = [conn]
    else
      @dmap[label].push(conn)

dispatcher = new Dispatcher

app.all('/in', (req, res)->
  labels = req.params "labels", []
  dests = []
  dests_contains = (conn) ->
    for dest in dests
      return true if dest == conn
    return false

  for label in labels
    conns = dispatcher[label]
    for conn in conns
      if not dests_contains(conn)
        dests.push(conn)

  for dest in dests
    console.log dest
    # dest.emit(req.params "obj")
)

app.all('/register', (req, res)->
  labels = req.param "labels", []
  for label in labels
    conn = {}
    dispatcher.add(label, label)
)

app.listen(3000)
