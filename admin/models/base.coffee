Spine = require('spine/core')

class BaseModel extends Spine.Model

  @alphaSort: (a, b) ->
    if a.name?
      if a.name > b.name then 1 else -1
    else if a.title?
      if a.title > b.title then 1 else -1

  @queryOn: ['name','title']

  @filter: (obj) ->
    return @all() unless obj
    query = obj.query.toLowerCase()
    siteId = obj.siteId.toLowerCase()
    @select (item) =>
      # See if matching any of the properties to filter on
      matchedQuery = false
      for p in @queryOn
        matchedQuery = matchedQuery or item[p]?.toLowerCase().indexOf(query) isnt -1
      matchedSite = if siteId and item.site then item.site is siteId else true
      if query and siteId
        matchedQuery and matchedSite
      else if query
        matchedQuery
      else if siteId
        matchedSite
      else
        true

module.exports = BaseModel
