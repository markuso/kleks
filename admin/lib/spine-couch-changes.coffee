db       = require "db"
duality  = require "duality/core"
session  = require "session"


feeds = {} # Cache `_changes` feeds by their url


Spine.Model.CouchChanges = (opts = {})->
  opts.url = opts.url or duality.getDBURL()
  opts.handler = Spine.Model.CouchChanges.Changes unless opts.handler
  feeds[opts.url] or feeds[opts.url] =
    changes: new opts.handler opts
    extended: ->
      # need to keep _rev around to support changes feed processing
      @attributes.push "_rev" unless @attributes[ "_rev" ]
      @changes.subscribe @className, @


Spine.Model.CouchChanges.Changes = class Changes
  subscribers: {}
  query: include_docs: yes

  constructor: (options = {})->
    @url = options.url
    @startListening()

  subscribe: (classname, klass) =>
    @subscribers[classname.toLowerCase()] = klass

  startListening: =>
    db.use(@url).changes @query, @handler()

  # returns handler which you may disable by setting handler.disabled flag `true`
  handler: -> self = (err, resp) =>
    if self.disabled then false
    else if err then false # TODO? @trigger error
    else
      @acceptChanges resp?.results
      true

  acceptChanges: (changes)->
    return unless changes
    Spine.CouchAjax.disable =>
      for doc in changes
        if modelname = doc.doc?.modelname
          klass = @subscribers[modelname]
        unless klass
          console.warn "changes: can't find subscriber for #{doc.doc.modelname}"
          continue
        atts = doc.doc
        atts.id = atts._id unless atts.id
        try
          obj = klass.find atts.id
          if doc.deleted
            obj.destroy()
          else
            unless obj._rev is atts._rev
              obj.updateAttributes atts
        catch e
          klass.create atts unless doc.deleted


# Start listening for _changes only when user is authenticated
#   and stop listening for changes when he logged out
Spine.Model.CouchChanges.PrivateChanges = class PrivateChanges extends Changes
  startListening: =>
    session.on "change", @authChanged

  authChanged: (userCtx)=>
    if userCtx.name
      @currentHandler.disabled = true if @currentHandler
      @currentHandler = @handler()
      db.use(@url).changes @query, @currentHandler
    else
      @currentHandler.disabled = true if @currentHandler
