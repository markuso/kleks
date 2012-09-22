Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Collection  = require('models/collection')


class Collections extends Spine.Controller
  className: 'collections panel'

  constructor: ->
    super
    # @active @render
    Collection.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      collections: Collection.filter(@filterObj)
    @el.html templates.render('collections.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


module.exports = Collections