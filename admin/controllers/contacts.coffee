Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Contact     = require('models/contact')


class ContactForm extends Spine.Controller
  className: 'contact form panel'

  elements:
    '.item-title':        'itemTitle'
    '.error-message':     'errorMessage'
    'form':               'form'
    '.save-button':       'saveButton'
    '.cancel-button':     'cancelButton'

  events:
    'submit form':          'preventSubmit'
    'click .save-button':   'save'
    'click .cancel-button': 'cancel'
    'click .delete-button': 'destroy'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @title = 'Copy Contact'
        @item = Contact.find(params.id.split('-')[1]).dup()
      else
        @item = Contact.find(params.id)
        @title = @item.name
    else
      @title = 'New Contact'
      @item = {}
    
    @html templates.render('contact-form.html', {}, @item)

    @itemTitle.html @title

  save: (e) ->
    e.preventDefault()
    if @editing
      @item.fromForm(@form)
    else
      @item = new Contact().fromForm(@form)
    
    # Save the item and make sure it validates
    if @item.save()
      @back()
    else
      msg = @item.validate()
      @showError msg

  showError: (msg) ->
    @errorMessage.html(msg).show()
    @el.scrollTop(0, 0)
  
  destroy: (e) ->
    e.preventDefault()
    if @item and confirm "Are you sure you want to delete this #{@item.constructor.name}?"
      @item.destroy()
      @back()
  
  cancel: (e) ->
    e.preventDefault()
    if @dirtyForm
      if confirm "You may have some unsaved changes.\nAre you sure you want to cancel?"
        @back()
    else
      @back()

  back: ->
    @navigate('/contacts/list')

  preventSubmit: (e) ->
    e.preventDefault()
    
  deactivate: ->
    @el.scrollTop(0, 0)
    super


class ContactList extends Spine.Controller
  className: 'contact list panel'

  constructor: ->
    super
    # @active @render
    Contact.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      contacts: Contact.filter(@filterObj).sort(Contact.nameSort)
    @html templates.render('contacts.html', {}, context)

  filter: (@filterObj) =>
    @render()


class Contacts extends Spine.Stack
  className: 'contacts panel'

  controllers:
    list: ContactList
    form: ContactForm

  default: 'list'

  routes:
    '/contacts/list': 'list'
    '/contact/new':   'form'
    '/contact/:id':   'form'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Contacts