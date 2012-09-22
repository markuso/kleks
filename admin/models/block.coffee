Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Block extends BaseModel
  @configure "Block", "site", "code", "name", "content"
  
  @extend Spine.Model.CouchAjax
  
  @queryOn: ['name','code']
    
  validate: ->
    return 'Name is required' unless @name
    return 'Code is required' unless @code

module.exports = Block
