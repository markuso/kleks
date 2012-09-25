Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Essay extends BaseModel
  @configure "Essay", "site", "slug", "title", "intro", "body", "published", "published_at", "updated_at", "author_id", "sponsor_id", "sponsor_start", "sponsor_end", "collections"
  
  @extend Spine.Model.CouchAjax
  
  @titleSort: (a, b) ->
    if (a.title or a.published_at) > (b.title or b.published_at) then 1 else -1

  @dateSort: (a, b) ->
    if (a.published_at or a.title) > (b.published_at or b.title) then 1 else -1

  @queryOn: ['title','slug']
    
  validate: ->
    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Title is required' unless @title
    if @sponsor_id
      return 'Sponsor Start Date is required' unless @sponsor_start
      return 'Sponsor End Date is required' unless @sponsor_end
      if new Date(@sponsor_start) >= new Date(@sponsor_end)
        return 'Sponsor Start Date cannot be later the End Date'

module.exports = Essay
