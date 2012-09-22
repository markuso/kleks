Spine       = require('spine/core')
$           = Spine.$
templates   = require('duality/templates')


class MainNav extends Spine.Controller
  className: 'main navbar'

  constructor: ->
    super
    @render()

  render: =>
    @el.html templates.render('main-nav.html', {}, {})
    @


module.exports = MainNav