Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

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
    '.save-button':            'saveButton'
    '.cancel-button':          'cancelButton'

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
        @title = 'Copy Sponsor'
        @item = Sponsor.find(params.id.split('-')[1]).dup()
      else
        @item = Sponsor.find(params.id)
        @title = @item.name
    else
      @title = 'New Sponsor'
      @item = {}
    
    @item.contacts = Contact.all().sort(Contact.nameSort)
    @html templates.render('sponsor-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formContactId.val(@item.contact_id)
      @formFormat.val(@item.format)

  save: (e) ->
    e.preventDefault()
    if @editing
      @item.fromForm(@form)
    else
      @item = new Sponsor().fromForm(@form)
    
    # Save the item and make sure it validates
    if @item.save()
      @back()
    else
      msg = @item.validate()
      @showError msg

  showError: (msg) ->
    @errorMessage.html(msg).show()
    @el.scrollTop(0, 0)
  
  destroy: ->
    e.preventDefault()
    if @item and confirm "Are you sure you want to delete this #{@item.constructor.name}?"
      @item.destroy()
      @back()
  
  cancel: (e) ->
    e.preventDefault
    if @dirtyForm
      if confirm "You may have some unsaved changes.\nAre you sure you want to cancel?"
        @back()
    else
      @back()

  back: ->
    @navigate('/sponsors/list')

  preventSubmit: (e) ->
    e.preventDefault
    
  deactivate: ->
    super
    @el.scrollTop(0, 0)


class SponsorList extends Spine.Controller
  className: 'sponsor list panel'

  constructor: ->
    super
    # @active @render
    Sponsor.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      sponsors: Sponsor.filter(@filterObj).sort(Sponsor.nameSort)
    @el.html templates.render('sponsors.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


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


module.exports = Sponsors