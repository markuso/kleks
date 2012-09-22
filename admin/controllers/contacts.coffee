Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Contact     = require('models/contact')


class Contacts extends Spine.Controller
  className: 'contacts panel'

  constructor: ->
    super
    # @active @render
    Contact.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      contacts: Contact.filter(@filterObj)
    @el.html templates.render('contacts.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


module.exports = Contacts