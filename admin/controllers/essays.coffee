Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Essay       = require('models/essay')


class Essays extends Spine.Controller
  className: 'essays panel'

  constructor: ->
    super
    # @active @render
    Essay.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      essays: Essay.filter(@filterObj)
    @el.html templates.render('essays.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


module.exports = Essays