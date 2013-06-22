Spine = require('spine/core')
utils = require('lib/utils')

BaseModel = require('models/base')

class Site extends BaseModel
  @configure "Site", "_id", "name", "name_html", "tagline", "menu_html", "header_html", "bottom_html", "footer_html", "link", "social_links", "theme", "css", "seo_description", "seo_keywords", "google_analytics_code", "editor_email", "admin_email", "default_ad_unit", "default_ad_enabled"
  
  @extend @CouchAjax
  @extend @CouchChanges
    handler: @CouchChanges.PrivateChanges
  
  @queryOn: ['name','tagline','_id']
    
  validate: ->
    return 'Site ID is required' unless @_id
    return 'Name is required' unless @name
    return 'Name HTML is required' unless @name_html

    # Validate the `_id` to be unique in the system
    if @isNew()
      found = Site.exists(@_id)
      return 'Site ID has been already used.' if found

    # Convert some boolean properties
    @default_ad_enabled = Boolean(@default_ad_enabled)

    return false

module.exports = Site
