Spine       = require('spine/core')
# $           = Spine.$
templates   = require('duality/templates')
settings    = require('settings/root')

Site        = require('models/site')


class SiteForm extends Spine.Controller
  className: 'site form panel'

  elements:
    '.item-title':        'itemTitle'
    '.error-message':     'errorMessage'
    'form':               'form'
    'input[name=_id]':    'formSiteId'
    'select[name=theme]': 'formTheme'
    '.social-links-list': 'socialLinksList'
    '.save-button':       'saveButton'
    '.cancel-button':     'cancelButton'

  events:
    'submit form':            'preventSubmit'
    'change *[name]':         'markAsDirty'
    'keyup *[name]':          'markAsDirty'
    'click .save-button':     'save'
    'click .cancel-button':   'cancel'
    'click .delete-button':   'destroy'
    'click .add-social-link': 'addSocialLink'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @dirtyForm = false
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @title = 'Copy Site'
        @item = Site.find(params.id.split('-')[1]).dup()
        # Important to indicate that we are creating a new record
        @editing = false
      else
        @item = Site.find(params.id)
        @title = @item.name
    else
      @title = 'New Site'
      @item = {}
    
    @item.themes = settings.app.themes
    @html templates.render('site-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formTheme.val(@item.theme)
      @formSiteId.prop('readonly', true)
    else:
      @addSocialLink()

  addSocialLink: (e) ->
    e?.preventDefault()
    @socialLinksList.append templates.render('partials/link-form.html', {}, {})

  save: (e) ->
    e.preventDefault()
    if not navigator.onLine
      alert "Can not save. You are OFFLINE."
      return
      
    if @editing
      @item.fromForm(@form)
    else
      @item = new Site().fromForm(@form)

    # Construct the social links list object
    links = []
    @socialLinksList.find('.social-link-form').each ->
      label = $.trim $(@).find('input[name=link_label]').val()
      url = $.trim $(@).find('input[name=link_url]').val()
      code = $.trim $(@).find('input[name=link_code]').val()
      if label and url
        links.push label: label, url: url, code: code
    @item.social_links = links
    
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
    @navigate('/sites/list')

  preventSubmit: (e) ->
    e.preventDefault()
    return false
    
  deactivate: ->
    @el.scrollTop(0)
    super


class SiteList extends Spine.Controller
  className: 'site list panel'

  events:
    'click h1 .count':    'reload'

  constructor: ->
    super
    # @active @render
    Site.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      sites: Site.filter(@filterObj).sort(Site.nameSort)
    @html templates.render('sites.html', {}, context)

  filter: (@filterObj) =>
    @render()
    @el.scrollTop(0)

  reload: ->
    Site.fetch()


class Sites extends Spine.Stack
  className: 'sites panel'

  controllers:
    list: SiteList
    form: SiteForm

  default: 'list'

  routes:
    '/sites/list': 'list'
    '/site/new':   'form'
    '/site/:id':   'form'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Sites