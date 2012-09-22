Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Essay       = require('models/essay')

class Dashboard extends Spine.Controller
  className: 'authors panel'

  constructor: ->
    super
    @active @render
    Essay.bind 'change fetch', @render

  render: =>
    context = 
      drafts: Essay.findAllByAttribute('published', true)
    @el.html templates.render('dashboard.html', {}, context)
    @


module.exports = Dashboard