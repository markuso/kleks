Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Block extends BaseModel
  @configure "Block", "site", "code", "name", "content"
  
  @extend Spine.Model.CouchAjax
  
  @queryOn: ['name','code']
    
  validate: ->
    return 'Site is required' unless @site
    return 'Code is required' unless @code
    return 'Name is required' unless @name
    return 'Content is required' unless @content

module.exports = Block
