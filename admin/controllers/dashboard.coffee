Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Essay       = require('models/essay')
Scene       = require('models/scene')


class DashboardOne extends Spine.Controller
  className: 'dashboard one panel'

  constructor: ->
    super
    # @active @render
    Essay.bind 'change refresh', @render
    Scene.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      essays: Essay.select(@selectFilter)
      scenes: Scene.select(@selectFilter)
    @html templates.render('dashboard.html', {}, context)

  selectFilter: (item) =>
    query = @filterObj?.query.toLowerCase()
    siteId = @filterObj?.siteId.toLowerCase()
    matchedQuery = query and item.title.toLowerCase().indexOf(query) isnt -1
    matchedSite = siteId and item.site is siteId
    if query and siteId
      matchedQuery and matchedSite and not item.published
    else if query
      matchedQuery and not item.published
    else if siteId
      matchedSite and not item.published
    else
      not item.published

  filter: (@filterObj) =>
    @render()
    @el.scrollTop(0)


class Dashboard extends Spine.Stack
  className: 'dashboards panel'

  controllers:
    one: DashboardOne

  default: 'one'

  routes:
    '/dashboard/one': 'one'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Dashboard