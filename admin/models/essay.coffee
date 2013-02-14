Spine = require('spine/core')
require('lib/spine-couch-ajax')

utils = require('lib/utils')
moment = require('lib/moment')

BaseModel = require('models/base')

class Essay extends BaseModel
  @configure "Essay", "site", "slug", "title", "intro", "body", "photo", "published", "published_at", "updated_at", "author_id", "sponsor_id", "sponsor_start", "sponsor_end", "sponsors_history", "collections", "_attachments"
  
  @extend @CouchAjax
  
  @alphaSort: (a, b) ->
    if (a.title or a.published_at) > (b.title or b.published_at) then 1 else -1

  @dateSort: (a, b) ->
    if (a.published_at or a.title) < (b.published_at or b.title) then 1 else -1

  @queryOn: ['title','slug']
    
  validate: ->
    @slug = utils.cleanSlug @slug
    
    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Title is required' unless @title

    # Validate the `slug` to be unique within site
    found = Essay.select (essay) =>
      matched = essay.site is @site and essay.slug is @slug
      if @isNew()
        matched
      else
        essay.id isnt @id and matched
    return 'Slug has been already used for this site.' if found.length

    # Take care of some dates
    @updated_at = moment.utc().format()

    published_at = moment(@published_at) or moment()
    return "Published #{utils.msg.DATE_NOT_VALID}" unless published_at.isValid()
    @published_at = published_at.utc().format()

    # Convert some boolean properties
    @published = Boolean(@published)

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
    @body = utils.cleanContent @body

    return false


module.exports = Essay
