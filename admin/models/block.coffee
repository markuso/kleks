Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

class Block extends BaseModel
  @configure "Block", "site", "code", "name", "content", "photo", "enabled", "_attachments"
  
  @extend @CouchAjax
  
  @queryOn: ['name','code']
    
  validate: ->
    @code = utils.cleanCode @code

    return 'Site is required' unless @site
    return 'Code is required' unless @code
    return 'Name is required' unless @name
    return 'Content is required' unless @content

    # Validate the `code` to be unique within site
    found = Block.select (block) =>
      matched = block.site is @site and block.code is @code
      if @isNew()
        matched
      else
        block.id isnt @id and matched
    return 'Code has been already used for this site.' if found.length

    # Convert some boolean properties
    @enabled = Boolean(@enabled)

    # Some content transformation
    @content = utils.cleanContent @content

    return false


module.exports = Block
