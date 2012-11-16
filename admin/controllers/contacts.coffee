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
    'change *[name]':       'markAsDirty'
    'keyup *[name]':        'markAsDirty'
    'click .save-button':   'save'
    'click .cancel-button': 'cancel'
    'click .delete-button': 'destroy'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @dirtyForm = false
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @title = 'Copy Contact'
        @item = Contact.find(params.id.split('-')[1]).dup()
        # Important to indicate that we are creating a new record
        @editing = false
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
    if not navigator.onLine
      alert "Can not save. You are OFFLINE."
      return
      
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
    @el.scrollTop(0)
  
  destroy: (e) ->
    e.preventDefault()
    if @item and confirm "Are you sure you want to delete this item?"
      @item.destroy()
      @back()

  markAsDirty: =>
    @dirtyForm = true
    @saveButton.addClass('glow')
  
  cancel: (e) ->
    e.preventDefault()
    if @dirtyForm
      if confirm "You may have some unsaved changes.\nAre you sure you want to proceed?"
        @back()
    else
      @back()

  back: ->
    @navigate('/contacts/list')

  preventSubmit: (e) ->
    e.preventDefault()
    return false
    
  deactivate: ->
    @el.scrollTop(0)
    super


class ContactList extends Spine.Controller
  className: 'contact list panel'

  events:
    'click h1 .count':    'reload'

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
    @el.scrollTop(0)

  reload: ->
    Contact.fetch()


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