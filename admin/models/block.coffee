Spine = require('spine/core')
require('lib/spine-couch-ajax')

class Block extends Spine.Model
  @configure "Block", "site", "code", "name", "content"
  
  @extend Spine.Model.CouchAjax
  
  @nameSort: (a, b) ->
    if a.name > b.name then 1 else -1
    
  validate: ->
    return 'Name is required' unless @name

module.exports = Block
