Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

class Redirect extends BaseModel
  @configure "Redirect", "_id", "site", "slug", "location"
  
  @extend @CouchAjax
  
  @queryOn: ['slug','location']
    
  validate: ->
    return 'ID is required' unless @_id
    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Location is required' unless @location

    # Validate the `_id` to be unique in the system
    if @isNew()
      found = Redirect.exists(@_id)
      return 'ID has been already used.' if found

    return false

module.exports = Redirect
