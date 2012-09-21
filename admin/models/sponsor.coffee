Spine = require('spine/core')
require('lib/spine-couch-ajax')

class Sponsor extends Spine.Model
  @configure "Sponsor", "format", "name", "url", "label", "content", "note", "contact_id"
  
  @extend Spine.Model.CouchAjax
  
  @nameSort: (a, b) ->
    if a.name > b.name then 1 else -1
    
  validate: ->
    @format ?= 'text'
    return 'Name is required' unless @name

module.exports = Sponsor
