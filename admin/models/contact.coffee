Spine = require('spine/core')
require('lib/spine-couch-ajax')

class Contact extends Spine.Model
  @configure "Contact", "name", "email", "note"
  @extend Spine.Model.CouchAjax
  
  @nameSort: (a, b) ->
    if a.name > b.name then 1 else -1
    
  validate: ->
    return 'Name is required' unless @name

module.exports = Contact
