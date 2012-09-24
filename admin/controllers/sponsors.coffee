Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Sponsor     = require('models/sponsor')


class Sponsors extends Spine.Controller
  className: 'sponsors panel'

  constructor: ->
    super
    # @active @render
    Sponsor.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      sponsors: Sponsor.filter(@filterObj).sort(Sponsor.nameSort)
    @el.html templates.render('sponsors.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


module.exports = Sponsors