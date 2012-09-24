Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Author      = require('models/author')


class Authors extends Spine.Controller
  className: 'authors panel'

  constructor: ->
    super
    # @active @render
    Author.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      authors: Author.filter(@filterObj).sort(Author.nameSort)
    @el.html templates.render('authors.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


module.exports = Authors