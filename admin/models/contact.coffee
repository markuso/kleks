Spine = require('spine/core')
utils = require('lib/utils')

BaseModel = require('models/base')

class Contact extends BaseModel
  @configure "Contact", "name", "email", "note"
  
  @extend @CouchAjax
  @extend @CouchChanges
    handler: @CouchChanges.PrivateChanges
  
  @queryOn: ['name','email']
    
  validate: ->
    return 'Name is required' unless @name

    return false

module.exports = Contact
