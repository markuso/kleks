Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

class Site extends BaseModel
  @configure "Site", "_id", "name", "name_html", "tagline", "menu_html", "footer_html", "link", "theme", "css", "seo_description", "seo_keywords", "google_analytics_code"
  
  @extend Spine.Model.CouchAjax
  
  @queryOn: ['name','tagline','_id']
    
  validate: ->
    return 'Site ID is required' unless @_id
    return 'Name is required' unless @name
    return 'Name HTML is required' unless @name_html

    return false

module.exports = Site
