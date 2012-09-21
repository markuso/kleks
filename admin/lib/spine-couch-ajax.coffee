Spine   = require('spine/core')
$       = Spine.$
Model   = Spine.Model
{_}     = require("underscore")
duality = require("duality/core")

Spine.Model.include
  toJSON: ->
    result = {}
    for key in @constructor.attributes when key of @
      if typeof @[key] is 'function'
        result[key] = @[key]()
      else
        result[key] = @[key]
    result.id = result._id = @_id if @_id
    result

Spine.Model.extend
  fromJSON: (objects) ->
    make_object = (val) =>
      val.id = val._id unless val.id
      val._id = val.id unless val._id
      new @(val)
    return unless objects
    if typeof objects is 'string'
      objects = JSON.parse(objects)
    if Spine.isArray(objects)
      for value in objects
        make_object(value)
    else
      make_object(objects)

CouchAjax =
  getURL: (object) ->
    object and object.url?() or object.url

  enabled:  true
  pending:  false
  requests: []

  disable: (callback) ->
    @enabled = false
    do callback
    @enabled = true

  requestNext: ->
    next = @requests.shift()
    if next
      @request(next)
    else
      @pending = false

  request: (callback) ->
    (do callback).complete(=> do @requestNext)
      
  queue: (callback) ->
    return unless @enabled
    if @pending
      @requests.push(callback)
    else
      @pending = true
      @request(callback)    
    callback
    
class Base
  defaults:
    contentType: 'application/json'
    dataType: 'json'
    processData: false
    headers: {'X-Requested-With': 'XMLHttpRequest'}
  
  ajax: (params, defaults) ->
    $.ajax($.extend({}, @defaults, defaults, params))
    
  queue: (callback) ->
    CouchAjax.queue(callback)

class Collection extends Base
  constructor: (@model) -> 
    
  find: (id, params) ->
    record = new @model(id: id)
    @ajax(
      params,
      type: 'GET',
      url:  CouchAjax.getURL(record)
    ).success(@recordsResponse)
     .error(@errorResponse)
    
  all: (params) ->
    @ajax(
      params,
      type: 'GET',
      url:  CouchAjax.getURL(@model)
    ).success(@recordsResponse)
     .error(@errorResponse)
    
  fetch: (params = {}) ->
    if id = params.id
      delete params.id
      @find(id, params).success (record) =>
        @model.refresh(_.pluck(record.rows, "doc"))
    else
      @all(params).success (records) =>
        @model.refresh(_.pluck(records.rows, "doc"))
    
  recordsResponse: (data, status, xhr) =>
    @model.trigger('ajaxSuccess', null, status, xhr)

  errorResponse: (xhr, statusText, error) =>
    @model.trigger('ajaxError', null, xhr, statusText, error)

class Singleton extends Base
  constructor: (@record) ->
    @model = @record.constructor
  
  reload: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'GET'
        url:  CouchAjax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))
  
  create: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'POST'
        data: JSON.stringify(@record)
        url:  CouchAjax.getURL(@model)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  update: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'PUT'
        data: JSON.stringify(@record)
        url:  CouchAjax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))
  
  destroy: (params, options) ->
    @queue =>
      @ajax(
        params,
        type: 'DELETE'
        url:  CouchAjax.getURL(@record)
      ).success(@recordResponse(options))
       .error(@errorResponse(options))

  # Private

  recordResponse: (options = {}) =>
    (data, status, xhr) =>
      if Spine.isBlank(data)
        data = false
      else if data.rows
        data = @model.fromJSON(_.pluck(data.rows, "doc"))
      else
        data = @model.fromJSON(data)
    
      CouchAjax.disable =>
        if data
          # ID change, need to do some shifting
          if data.id and @record.id isnt data.id
            @record.changeID(data.id)

          # Update with latest data
          @record.updateAttributes(data.attributes())
        
      @record.trigger('ajaxSuccess', data, status, xhr)
      options.success?.apply(@record)
      
  errorResponse: (options = {}) =>
    (xhr, statusText, error) =>
      @record.trigger('ajaxError', xhr, statusText, error)
      options.error?.apply(@record)

# CouchAjax endpoint
Model.host = ''

Include =
  ajax: -> new Singleton(this)

  url: ->
    base = CouchAjax.getURL(@constructor)
    base += '/' unless base.charAt(base.length - 1) is '/'
    base += encodeURIComponent(@id)
    base
    
Extend = 
  ajax: -> new Collection(this)

  url: ->
    "#{duality.getBaseURL()}/spine-adapter/#{@className.toLowerCase()}"
      
Model.CouchAjax =
  extended: ->
    @fetch @ajaxFetch
    @change @ajaxChange
    
    @extend Extend
    @include Include
    
  ajaxFetch: ->
    @ajax().fetch(arguments...)
    
  ajaxChange: (record, type, options = {}) ->
    record.ajax()[type](options.ajax, options)
    
Model.CouchAjax.Methods = 
  extended: ->
    @extend Extend
    @include Include
    
# Globals
CouchAjax.defaults   = Base::defaults
Spine.CouchAjax      = CouchAjax
module?.exports = CouchAjax