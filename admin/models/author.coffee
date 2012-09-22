Spine = require('spine/core')
require('lib/spine-couch-ajax')

class Author extends Spine.Model
  @configure "Author", "site", "name", "email", "bio", "links", "photo"
  
  @extend Spine.Model.CouchAjax
  
  @nameSort: (a, b) ->
    if a.name > b.name then 1 else -1
    
  validate: ->
    return 'Name is required' unless @name

module.exports = Author
