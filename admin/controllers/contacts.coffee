Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Contact     = require('models/contact')


class Contacts extends Spine.Controller
  className: 'contacts panel'

  constructor: ->
    super
    @active @render
    Contact.bind 'change fetch', @render

  render: =>
    context = 
      contacts: Contact.all()
    @el.html templates.render('contacts.html', {}, context)
    @


module.exports = Contacts