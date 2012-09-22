Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Block       = require('models/block')


class Blocks extends Spine.Controller
  className: 'blocks panel'

  constructor: ->
    super
    @active @render
    Block.bind 'change fetch', @render

  render: =>
    context = 
      blocks: Block.all()
    @el.html templates.render('blocks.html', {}, context)
    @


module.exports = Blocks