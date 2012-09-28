Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

class Essay extends BaseModel
  @configure "Essay", "site", "slug", "title", "intro", "body", "photo", "published", "published_at", "updated_at", "author_id", "sponsor_id", "sponsor_start", "sponsor_end", "collections", "_attachments"
  
  @extend Spine.Model.CouchAjax
  
  @titleSort: (a, b) ->
    if (a.title or a.published_at) > (b.title or b.published_at) then 1 else -1

  @dateSort: (a, b) ->
    if (a.published_at or a.title) > (b.published_at or b.title) then 1 else -1

  @queryOn: ['title','slug']
    
  validate: ->
    @slug = utils.cleanSlug @slug
    
    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Title is required' unless @title

    # Take care of some dates
    @updated_at = new Date().toJSON()
    try
      if @published_at
        @published_at = new Date(@published_at).toJSON()
      else
        @published_at = new Date().toJSON()
    catch error
      return "Date format is wrong. Use this format: 'Feb 20 2012 6:30 PM'"

    # Convert some boolean properties
    @published = Boolean(@published)

    # Sponsor dates if setting a sponsor
    if @sponsor_id
      return 'Sponsor Start Date is required' unless @sponsor_start
      return 'Sponsor End Date is required' unless @sponsor_end
      try
        if new Date(@sponsor_start).toJSON() >= new Date(@sponsor_end).toJSON()
          return 'Sponsor Start Date cannot be later than End Date'
      catch error
        return "Sponsor date format is wrong. Use this format: 'Feb 20 2012 6:30 PM'"

    # Some content transformation
    @intro = utils.cleanContent @intro
    @body = utils.cleanContent @body

    return false


module.exports = Essay
