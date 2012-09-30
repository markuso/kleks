Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')
utils       = require('lib/utils')

FileUploadUI  = require('controllers/ui/file-upload')

Collection  = require('models/collection')
Sponsor     = require('models/sponsor')
Site        = require('models/site')


class CollectionForm extends Spine.Controller
  className: 'collection form panel'

  elements:
    '.item-title':             'itemTitle'
    '.error-message':          'errorMessage'
    'form':                    'form'
    'select[name=site]':       'formSite'
    'select[name=sponsor_id]': 'formSponsorId'
    'input[name=name]':        'formName'
    'input[name=pinned]':      'formPinned'
    '.upload-ui':              'fileUploadContainer'
    '.save-button':            'saveButton'
    '.cancel-button':          'cancelButton'

  events:
    'submit form':              'preventSubmit'
    'click .save-button':       'save'
    'click .cancel-button':     'cancel'
    'click .delete-button':     'destroy'
    'change select[name=site]': 'siteChange'
    'blur input[name=slug]':    'updateSlug'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @title = 'Copy Collection'
        @item = Collection.find(params.id.split('-')[1]).dup()
      else
        @item = Collection.find(params.id)
        @title = @item.name
    else
      @title = 'New Collection'
      @item = {}

    @item._attachments ?= {}
    
    @item.sites = Site.all().sort(Site.nameSort)
    @item.sponsors = Sponsor.all().sort(Sponsor.nameSort)
    @html templates.render('collection-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formSite.val(@item.site)
      @formSponsorId.val(@item.sponsor_id)
      @formPinned.prop('checked', @item.pinned)
    else
      @formSite.val(@stack.stack.filterBox.siteId)
    @siteChange()

    # Files upload area
    @fileUploadUI = new FileUploadUI
      docId: @item.id
      selectedFile: @item.photo
      attachments: @item._attachments
    @fileUploadContainer.html @fileUploadUI.el

  siteChange: ->
    $siteSelected = @formSite.parents('.field').find('.site-selected')
    site = Site.exists(@formSite.val())
    if site
      $siteSelected.html "<div class=\"site-name theme-#{site.theme}\">#{site.name_html}</div>"
    else
      $siteSelected.html ""

  updateSlug: (e) =>
    slug = $(e.currentTarget)
    unless slug.val()
      slug.val utils.cleanSlug(@formName.val())

  save: (e) ->
    e.preventDefault()
    if @editing
      @item.fromForm(@form)
    else
      @item = new Collection().fromForm(@form)

    @item._attachments = @fileUploadUI.attachments

    # Take care of some boolean checkboxes
    @item.pinned = @formPinned.is(':checked')

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
    @navigate('/collections/list')

  preventSubmit: (e) ->
    e.preventDefault()
    
  deactivate: ->
    @el.scrollTop(0, 0)
    super


class CollectionList extends Spine.Controller
  className: 'collection list panel'

  constructor: ->
    super
    # @active @render
    Collection.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      collections: Collection.filter(@filterObj).sort(Collection.nameSort)
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
    '/collections/list': 'list'
    '/collection/new':   'form'
    '/collection/:id':   'form'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Collections