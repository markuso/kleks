Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Site        = require('models/site')


class Sites extends Spine.Controller
  className: 'sites panel'

  constructor: ->
    super
    # @active @render
    Site.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      sites: Site.filter(@filterObj)
    @el.html templates.render('sites.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


module.exports = Sites