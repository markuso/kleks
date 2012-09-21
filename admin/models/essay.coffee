Spine = require('spine/core')
require('lib/spine-couch-ajax')

class Essay extends Spine.Model
  @configure "Essay", "site", "slug", "title", "intro", "body", "published", "published_at", "updated_at", "author_id", "sponsor_id", "collections"
  @extend Spine.Model.CouchAjax
  
  @titleSort: (a, b) ->
    if (a.title or a.published_at) > (b.title or b.published_at) then 1 else -1
    
  validate: ->
    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Title is required' unless @title

module.exports = Essay
