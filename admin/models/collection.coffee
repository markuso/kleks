Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')

BaseModel = require('models/base')

class Collection extends BaseModel
  @configure "Collection", "site", "slug", "name", "intro", "pinned", "updated_at", "sponsor_id", "sponsor_start", "sponsor_end", "_attachments"

  @extend Spine.Model.CouchAjax

  @queryOn: ['name','slug']
    
  validate: ->
    @slug = utils.cleanSlug @slug

    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Name is required' unless @name
    
    # Take care of some dates
    try
      if @updated_at
        @updated_at = new Date(@updated_at).toJSON()
      else
        @updated_at = new Date().toJSON()
    catch error
      return "Date format is wrong. Use this format: 'Feb 20 2012 6:30 PM'"
    
    # Convert some boolean properties
    @pinned = Boolean(@pinned)

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

    return false


module.exports = Collection
