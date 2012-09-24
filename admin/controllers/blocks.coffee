Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Block       = require('models/block')


class Blocks extends Spine.Controller
  className: 'blocks panel'

  constructor: ->
    super
    # @active @render
    Block.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      blocks: Block.filter(@filterObj).sort(Block.titleSort)
    @el.html templates.render('blocks.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


module.exports = Blocks