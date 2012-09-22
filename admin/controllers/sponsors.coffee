Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Sponsor     = require('models/sponsor')


class Sponsors extends Spine.Controller
  className: 'sponsors panel'

  constructor: ->
    super
    @active @render
    Sponsor.bind 'change fetch', @render

  render: =>
    context = 
      sponsors: Sponsor.all()
    @el.html templates.render('sponsors.html', {}, context)
    @


module.exports = Sponsors