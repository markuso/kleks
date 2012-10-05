Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

FileUploadUI  = require('controllers/ui/file-upload')

Block       = require('models/block')
Site        = require('models/site')


class BlockForm extends Spine.Controller
  className: 'block form panel'

  elements:
    '.item-title':             'itemTitle'
    '.error-message':          'errorMessage'
    'form':                    'form'
    'select[name=site]':       'formSite'
    'input[name=enabled]':     'formEnabled'
    '.upload-ui':              'fileUploadContainer'
    '.save-button':            'saveButton'
    '.cancel-button':          'cancelButton'

  events:
    'submit form':              'preventSubmit'
    'click .save-button':       'save'
    'click .cancel-button':     'cancel'
    'click .delete-button':     'destroy'
    'change select[name=site]': 'siteChange'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @title = 'Copy Block'
        @item = Block.find(params.id.split('-')[1]).dup()
      else
        @item = Block.find(params.id)
        @title = @item.name
    else
      @title = 'New Block'
      @item = {}

    @item._attachments ?= {}
    
    @item.sites = Site.all().sort(Site.nameSort)
    @html templates.render('block-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formSite.val(@item.site)
      @formEnabled.prop('checked', @item.enabled)
    else
      @formSite.val(@stack.stack.filterBox.siteId)
      @formEnabled.prop('checked', true)
    @siteChange()

  siteChange: ->
    $siteSelected = @formSite.parents('.field').find('.site-selected')
    site = Site.exists(@formSite.val())
    if site
      $siteSelected.html "<div class=\"site-name theme-#{site.theme}\">#{site.name_html}</div>"
    else
      $siteSelected.html ""

    # Files upload area
    @fileUploadUI = new FileUploadUI
      docId: @item.id
      selectedFile: @item.photo
      attachments: @item._attachments
    @fileUploadContainer.html @fileUploadUI.el

  save: (e) ->
    e.preventDefault()
    if @editing
      @item.fromForm(@form)
    else
      @item = new Block().fromForm(@form)

    @item._attachments = @fileUploadUI.attachments

    # Take care of some boolean checkboxes
    @item.enabled = @formEnabled.is(':checked')
    
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
    @navigate('/blocks/list')

  preventSubmit: (e) ->
    e.preventDefault()
    
  deactivate: ->
    @el.scrollTop(0, 0)
    super


class BlockList extends Spine.Controller
  className: 'block list panel'

  constructor: ->
    super
    # @active @render
    Block.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      blocks: Block.filter(@filterObj).sort(Block.titleSort)
    @html templates.render('blocks.html', {}, context)

  filter: (@filterObj) =>
    @render()
    @el.scrollTop(0, 0)


class Blocks extends Spine.Stack
  className: 'blocks panel'

  controllers:
    list: BlockList
    form: BlockForm

  default: 'list'

  routes:
    '/blocks/list': 'list'
    '/block/new':   'form'
    '/block/:id':   'form'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Blocks