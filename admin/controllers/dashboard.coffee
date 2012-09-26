Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Essay       = require('models/essay')


class DashboardOne extends Spine.Controller
  className: 'dashboard one panel'

  constructor: ->
    super
    # @active @render
    Essay.bind 'change refresh', @render

  render: =>
    context = 
      drafts: Essay.findAllByAttribute('published', false)
    @el.html templates.render('dashboard.html', {}, context)
    @


class Dashboard extends Spine.Stack
  className: 'dashboards panel'

  controllers:
    one: DashboardOne

  default: 'one'

  routes:
    '/dashboard/one': 'one'


module.exports = Dashboard