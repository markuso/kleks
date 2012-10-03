Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

class Author extends BaseModel
  @configure "Author", "site", "name", "email", "bio", "links", "photo"
  
  @extend @CouchAjax
  
  @queryOn: ['name','email']
    
  validate: ->
    return 'Name is required' unless @name
    return 'Email is required' unless @email
    return 'Bio is required' unless @bio

    return false

module.exports = Author
