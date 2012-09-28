Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

utils = require('lib/utils')

class Sponsor extends BaseModel
  @configure "Sponsor", "format", "name", "link", "label", "content", "note", "contact_id"
  
  @extend Spine.Model.CouchAjax

  @queryOn: ['name','content','link','format']
    
  validate: ->
    @format ?= 'text'
    return 'Name is required' unless @name

    # Some content transformation
    @content = utils.cleanContent @content

    return false

module.exports = Sponsor
