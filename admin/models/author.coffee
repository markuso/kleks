Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Author extends BaseModel
  @configure "Author", "site", "name", "email", "bio", "links", "photo"
  
  @extend Spine.Model.CouchAjax
  
  @queryOn: ['name','email']
    
  validate: ->
    return 'Name is required' unless @name

module.exports = Author
