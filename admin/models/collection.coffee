Spine = require('spine/core')
require('lib/spine-couch-ajax')

class Collection extends Spine.Model
  @configure "Collection", "site", "slug", "name", "intro"
  
  @extend Spine.Model.CouchAjax
  
  @nameSort: (a, b) ->
    if a.name > b.name then 1 else -1
    
  validate: ->
    return 'Site is required' unless @site
    return 'Slug is required' unless @slug
    return 'Name is required' unless @name

module.exports = Collection
