Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

utils = require('lib/utils')

class Sponsor extends BaseModel
  @configure "Sponsor", "format", "name", "link", "label", "show_label", "content", "include_default_ad_unit", "image", "note", "contact_id", "_attachments"
  
  @extend @CouchAjax

  @queryOn: ['name','content','link','format']
    
  validate: ->
    @format ?= 'text'
    return 'Name is required' unless @name

    # Convert some boolean properties
    @show_label = Boolean(@show_label)
    @include_default_ad_unit = Boolean(@include_default_ad_unit)

    # Some content transformation
    @content = utils.cleanContent @content

    return false

module.exports = Sponsor
