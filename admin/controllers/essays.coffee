Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Essay       = require('models/essay')


class Essays extends Spine.Controller
  className: 'essays panel'

  constructor: ->
    super
    @active @render
    Essay.bind 'change fetch', @render

  render: =>
    context = 
      essays: Essay.all()
    @el.html templates.render('essays.html', {}, context)
    @


module.exports = Essays