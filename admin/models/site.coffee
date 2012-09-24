Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Site extends BaseModel
  @configure "Site", "_id", "name", "name_html", "tagline", "footer_html", "link", "theme", "css", "google_analytics_code"
  
  @extend Spine.Model.CouchAjax
  
  @queryOn: ['name','tagline','_id']
    
  validate: ->
    return 'Name is required' unless @name

module.exports = Site
