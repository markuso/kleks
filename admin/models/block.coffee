Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

class Block extends BaseModel
  @configure "Block", "site", "code", "name", "content"
  
  @extend Spine.Model.CouchAjax
  
  @queryOn: ['name','code']
    
  validate: ->
    @code = utils.cleanCode @code

    return 'Site is required' unless @site
    return 'Code is required' unless @code
    return 'Name is required' unless @name
    return 'Content is required' unless @content

    # Some content transformation
    @content = utils.cleanContent @content

    return false


module.exports = Block
