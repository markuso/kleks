Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Essay       = require('models/essay')
Video       = require('models/video')
Scene       = require('models/scene')


class DashboardOne extends Spine.Controller
  className: 'dashboard one panel'

  events:
    'click h1 .count':    'reload'

  constructor: ->
    super
    # @active @render
    Essay.bind 'change refresh', @render
    Video.bind 'change refresh', @render
    Scene.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    essaySortFunc = if @filterObj?.sortBy then Essay[@filterObj.sortBy] else Essay.dateSort
    videoSortFunc = if @filterObj?.sortBy then Video[@filterObj.sortBy] else Video.dateSort
    sceneSortFunc = if @filterObj?.sortBy then Scene[@filterObj.sortBy] else Scene.dateSort
    context = 
      essays: Essay.select(@selectFilter).sort(essaySortFunc)
      videos: Video.select(@selectFilter).sort(videoSortFunc)
      scenes: Scene.select(@selectFilter).sort(sceneSortFunc)
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

  reload: ->
    Essay.fetch()
    Video.fetch()
    Scene.fetch()


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