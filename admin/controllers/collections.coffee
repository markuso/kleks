Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Collection       = require('models/collection')


class Collections extends Spine.Controller
  className: 'collections panel'

  constructor: ->
    super
    @active @render
    Collection.bind 'change fetch', @render

  render: =>
    context = 
      collections: Collection.all()
    @el.html templates.render('collections.html', {}, context)
    @


module.exports = Collections