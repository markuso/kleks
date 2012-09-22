Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Sponsor extends BaseModel
  @configure "Sponsor", "format", "name", "link", "label", "content", "note", "contact_id"
  
  @extend Spine.Model.CouchAjax

  @queryOn: ['name','content','link','format']
    
  validate: ->
    @format ?= 'text'
    return 'Name is required' unless @name

module.exports = Sponsor
