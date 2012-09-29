Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils  = require('lib/utils')
moment = require('lib/moment')

BaseModel = require('models/base')

class Collection extends BaseModel
  @configure "Collection", "site", "slug", "name", "intro", "photo", "pinned", "updated_at", "sponsor_id", "sponsor_start", "sponsor_end", "sponsors_history", "_attachments"

  @extend Spine.Model.CouchAjax

  @queryOn: ['name','slug']
    
  validate: ->
    @slug = utils.cleanSlug @slug

    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Name is required' unless @name
    
    # Take care of some dates
    updated_at = moment(@updated_at)
    return "Updated #{utils.msg.DATE_NOT_VALID}" unless updated_at.isValid()
    @updated_at = updated_at.utc().format()
    
    # Convert some boolean properties
    @pinned = Boolean(@pinned)

    # Sponsor dates if setting a sponsor
    if @sponsor_id
      return 'Sponsor Start Date is required' unless @sponsor_start
      return 'Sponsor End Date is required' unless @sponsor_end
      sponsor_start = moment(@sponsor_start)
      sponsor_end = moment(@sponsor_end)
      return "Sponsor Start #{utils.msg.DATE_NOT_VALID}" unless sponsor_start.isValid()
      return "Sponsor End #{utils.msg.DATE_NOT_VALID}" unless sponsor_end.isValid()
      return 'Sponsor Start Date cannot be later than End Date' if sponsor_start >= sponsor_end
      # Save in UTC format string
      @sponsor_start = sponsor_start.utc().format()
      @sponsor_end = sponsor_end.utc().format()

    # Some content transformation
    @intro = utils.cleanContent @intro

    return false


module.exports = Collection
