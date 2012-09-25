Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Collection extends BaseModel
  @configure "Collection", "site", "slug", "name", "intro", "pinned", "updated_at", "sponsor_id", "sponsor_start", "sponsor_end"

  @extend Spine.Model.CouchAjax

  @queryOn: ['name','slug']
    
  validate: ->
    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Name is required' unless @name
    if @sponsor_id
      return 'Sponsor Start Date is required' unless @sponsor_start
      return 'Sponsor End Date is required' unless @sponsor_end
      if new Date(@sponsor_start) >= new Date(@sponsor_end)
        return 'Sponsor Start Date cannot be later the End Date'

module.exports = Collection
