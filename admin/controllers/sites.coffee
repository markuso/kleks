Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Site        = require('models/site')


class Sites extends Spine.Controller
  className: 'sites panel'

  constructor: ->
    super
    @active @render
    Site.bind 'change fetch', @render

  render: =>
    context = 
      sites: Site.all()
    @el.html templates.render('sites.html', {}, context)
    @


module.exports = Sites