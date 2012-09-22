Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Collection  = require('models/collection')
Sponsor     = require('models/sponsor')


class CollectionForm extends Spine.Controller
  className: 'collection form panel'

  elements:
    '.item-title': 'itemTitle'
    '.error-message': 'errorMessage'
    'form': 'form'
    'select[name=sponsor_id]': 'formSponsorId'
    '.save-button': 'saveButton'
    '.cancel-button': 'cancelButton'

  events:
    'submit form': 'preventSubmit'
    'click .save-button': 'save'
    'click .cancel-button': 'cancel'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @itemTitle.html 'Copy Collection'
        @item = Collection.find(params.id.split('-')[1]).dup()
      else
        @item = Collection.find(params.id)
        @itemTitle.html @item.name
    else
      @itemTitle.html 'New Collection'
      @item = {}
    
    @item.sponsors = Sponsor.all().sort(Sponsor.nameSort)
    @html templates.render('collection-form.html', {}, @item)
    
    # Set few initial form values
    if @editing
      @formSponsorId.val(@item.sponsor_id)

  save: (e) ->
    e.preventDefault()
    if @editing
      @item.fromForm(@mainForm)
    else
      @item = new Collection().fromForm(@mainForm)
    
    # Save the item and make sure it validates
    if @item.save()
      @back()
    else
      msg = @item.validate()
      @errorMessage.html(msg).show()
      @el.scrollTop(0, 0)
  
  cancel: (e) ->
    e.preventDefault
    if @dirtyForm
      sure = prompt "You may have some unsaved changes.\nAre you sure you want to cancel?"
      @back() if sure
    else
      @back()

  back: ->
    @navigate('/collections')

  preventSubmit: (e) ->
    e.preventDefault
    
  deactivate: ->
    super
    @el.scrollTop(0, 0)


class CollectionList extends Spine.Controller
  className: 'collection list panel'

  constructor: ->
    super
    # @active @render
    Collection.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      collections: Collection.filter(@filterObj)
    @html templates.render('collections.html', {}, context)

  filter: (@filterObj) =>
    @render()


class Collections extends Spine.Stack
  className: 'collections panel'

  controllers:
    list: CollectionList
    form: CollectionForm

  default: 'list'

  routes:
    # '/collections':    'list'
    '/collection':     'form'
    '/collection/:id': 'form'


module.exports = Collections