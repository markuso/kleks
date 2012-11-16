Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

FileUploadUI  = require('controllers/ui/file-upload')

Sponsor     = require('models/sponsor')
Contact     = require('models/contact')


class SponsorForm extends Spine.Controller
  className: 'sponsor form panel'

  elements:
    '.item-title':             'itemTitle'
    '.error-message':          'errorMessage'
    'form':                    'form'
    'select[name=contact_id]': 'formContactId'
    'select[name=format]':     'formFormat'
    'textarea[name=content]':  'formContent'
    '.upload-ui':              'fileUploadContainer'
    '.save-button':            'saveButton'
    '.cancel-button':          'cancelButton'

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
        @title = 'Copy Sponsor'
        @item = Sponsor.find(params.id.split('-')[1]).dup()
        # Important to indicate that we are creating a new record
        @editing = false
      else
        @item = Sponsor.find(params.id)
        @title = @item.name
        
      # Fetch missing data if need be
      if not @item.content?
        @item.ajax().reload {},
          success: =>
            @formContent.val(@item.content)
    else
      @title = 'New Sponsor'
      @item = {}

    @item._attachments ?= {}
    
    @item.contacts = Contact.all().sort(Contact.nameSort)
    @html templates.render('sponsor-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formContactId.val(@item.contact_id)
      @formFormat.val(@item.format)

    # Files upload area
    @fileUploadUI = new FileUploadUI
      docId: @item.id
      selectedFieldName: 'image'
      selectedFile: @item.image
      attachments: @item._attachments
      changeCallback: @markAsDirty
    @fileUploadContainer.html @fileUploadUI.el

  save: (e) ->
    e.preventDefault()
    if not navigator.onLine
      alert "Can not save. You are OFFLINE."
      return
      
    if @editing
      @item.fromForm(@form)
    else
      @item = new Sponsor().fromForm(@form)

    @item._attachments = @fileUploadUI.attachments
    
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
    @navigate('/sponsors/list')

  preventSubmit: (e) ->
    e.preventDefault()
    return false
    
  deactivate: ->
    @el.scrollTop(0)
    super


class SponsorList extends Spine.Controller
  className: 'sponsor list panel'

  events:
    'click h1 .count':    'reload'

  constructor: ->
    super
    # @active @render
    Sponsor.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      sponsors: Sponsor.filter(@filterObj).sort(Sponsor.nameSort)
    @html templates.render('sponsors.html', {}, context)

  filter: (@filterObj) =>
    @render()
    @el.scrollTop(0)

  reload: ->
    Sponsor.fetch()


class Sponsors extends Spine.Stack
  className: 'sponsors panel'

  controllers:
    list: SponsorList
    form: SponsorForm

  default: 'list'

  routes:
    '/sponsors/list': 'list'
    '/sponsor/new':   'form'
    '/sponsor/:id':   'form'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Sponsors