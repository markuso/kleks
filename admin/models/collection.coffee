Spine = require('spine/core')
require('lib/spine-couch-ajax')

BaseModel = require('models/base')

class Collection extends BaseModel
  @configure "Collection", "site", "slug", "name", "intro", "pinned", "updated_at", "sponsor_id"

  @extend Spine.Model.CouchAjax

  @queryOn: ['name','slug']
    
  validate: ->
    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Name is required' unless @name

module.exports = Collection
