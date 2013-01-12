Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')

Redirect    = require('models/redirect')
Site        = require('models/site')


class RedirectForm extends Spine.Controller
  className: 'redirect form panel'

  elements:
    '.item-title':        'itemTitle'
    '.error-message':     'errorMessage'
    'form':               'form'
    'select[name=site]':  'formSite'
    'input[name=slug]':   'formSlug'
    '.save-button':       'saveButton'
    '.cancel-button':     'cancelButton'

  events:
    'submit form':            'preventSubmit'
    'change *[name]':         'markAsDirty'
    'keyup *[name]':          'markAsDirty'
    'click .save-button':     'save'
    'click .cancel-button':   'cancel'
    'click .delete-button':   'destroy'
    'change select[name=site]': 'siteChange'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @dirtyForm = false
    # Get the redirect id from the url glob
    params.id = params.match[1]
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @title = 'Copy Redirect'
        @item = Redirect.find(params.id.split('-')[1]).dup()
        # Important to indicate that we are creating a new record
        @editing = false
      else
        @item = Redirect.find(params.id)
        @title = @item.slug
    else
      @title = 'New Redirect'
      @item = {}
    
    @item.sites = Site.all().sort(Site.nameSort)
    @html templates.render('redirect-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formSite.val(@item.site)
      @formSlug.prop('readonly', true).attr('title', 'Can not change the slug')
    else
      @formSite.val(@stack.stack.filterBox.siteId)
    @siteChange()

  siteChange: ->
    $siteSelected = @formSite.parents('.field').find('.site-selected')
    site = Site.exists(@formSite.val())
    if site
      $siteSelected.html "<div class=\"site-name theme-#{site.theme}\">#{site.name_html}</div>"
    else
      $siteSelected.html ""

  save: (e) ->
    e.preventDefault()
    if not navigator.onLine
      alert "Can not save. You are OFFLINE."
      return
      
    if @editing
      @item.fromForm(@form)
    else
      @item = new Redirect().fromForm(@form)
      @item._id = "r/#{@item.site}/#{@item.slug}"
    
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
    @navigate('/redirects/list')

  preventSubmit: (e) ->
    e.preventDefault()
    return false
    
  deactivate: ->
    @el.scrollTop(0)
    super


class RedirectList extends Spine.Controller
  className: 'redirect list panel fixed-header'

  events:
    'click h1 .count':    'reload'

  constructor: ->
    super
    # @active @render
    Redirect.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      redirects: Redirect.filter(@filterObj).sort(Redirect.nameSort)
    @html templates.render('redirects.html', {}, context)

  filter: (@filterObj) =>
    @render()
    @el.scrollTop(0)

  reload: ->
    Redirect.fetch()


class Redirects extends Spine.Stack
  className: 'redirects panel'

  controllers:
    list: RedirectList
    form: RedirectForm

  default: 'list'

  routes:
    '/redirects/list': 'list'
    '/redirect/new':   'form'
    '/redirect/*glob':   'form'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Redirects