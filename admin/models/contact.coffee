Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

class Contact extends BaseModel
  @configure "Contact", "name", "email", "note"
  
  @extend Spine.Model.CouchAjax
  
  @queryOn: ['name','email']
    
  validate: ->
    return 'Name is required' unless @name

    return false

module.exports = Contact
