Spine       = require('spine/core')
$           = Spine.$
templates   = require('duality/templates')


class MainNav extends Spine.Controller
  className: 'main navbar'

  constructor: ->
    super
    @render()
    @setup()

  render: =>
    @el.html templates.render('main-nav.html', {}, {})
    @

  setup: =>
    links = @el.find('li a')
    links.on 'click', (e) ->
      links.removeClass('active')
      $(@).addClass('active')


module.exports = MainNav