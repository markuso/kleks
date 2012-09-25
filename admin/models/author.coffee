Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Author extends BaseModel
  @configure "Author", "site", "name", "email", "bio", "links", "photo"
  
  @extend Spine.Model.CouchAjax
  
  @queryOn: ['name','email']
    
  validate: ->
    return 'Name is required' unless @name
    return 'Email is required' unless @email
    return 'Bio is required' unless @bio

module.exports = Author
