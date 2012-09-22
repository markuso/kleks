Spine = require('spine/core')
require('lib/spine-couch-ajax')

class Site extends Spine.Model
  @configure "Site", "name", "name_html", "tagline", "footer_html", "link", "theme", "css", "google_analytics_code"
  
  @extend Spine.Model.CouchAjax
  
  @nameSort: (a, b) ->
    if a.name > b.name then 1 else -1
    
  validate: ->
    return 'Name is required' unless @name

module.exports = Site
