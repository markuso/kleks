Spine       = require('spine/core')
$           = Spine.$
templates   = require('duality/templates')

Author      = require('models/author')
Site        = require('models/site')


class AuthorForm extends Spine.Controller
  className: 'author form panel'

  elements:
    '.item-title':             'itemTitle'
    '.error-message':          'errorMessage'
    'form':                    'form'
    'select[name=site]':       'formSite'
    'textarea[name=bio]':      'formBio'
    '.links-list':             'linksList'
    '.save-button':            'saveButton'
    '.cancel-button':          'cancelButton'

  events:
    'submit form':              'preventSubmit'
    'change *[name]':           'markAsDirty'
    'keyup *[name]':            'markAsDirty'
    'click .save-button':       'save'
    'click .cancel-button':     'cancel'
    'click .delete-button':     'destroy'
    'change select[name=site]': 'siteChange'
    'click .add-link':          'addLink'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @dirtyForm = false
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @title = 'Copy Author'
        @item = Author.find(params.id.split('-')[1]).dup()
        # Important to indicate that we are creating a new record
        @editing = false
      else
        @item = Author.find(params.id)
        @title = @item.name
        
      # Fetch missing data if need be
      if not @item.bio?
        @item.ajax().reload {},
          success: =>
            @formBio.val(@item.bio)
    else
      @title = 'New Author'
      @item = {}
    
    @item.sites = Site.all().sort(Site.nameSort)
    @html templates.render('author-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formSite.val(@item.site)
    else
      @formSite.val(@stack.stack.filterBox.siteId)
      @addLink()
    @siteChange()

    return @

  siteChange: ->
    $siteSelected = @formSite.parents('.field').find('.site-selected')
    site = Site.exists(@formSite.val())
    if site
      $siteSelected.html "<div class=\"site-name theme-#{site.theme}\">#{site.name_html}</div>"
    else
      $siteSelected.html ""

  addLink: (e) ->
    e?.preventDefault()
    @linksList.append templates.render('partials/link-form.html', {}, {})

  save: (e) ->
    e.preventDefault()
    if not navigator.onLine
      alert "Can not save. You are OFFLINE."
      return
      
    if @editing
      @item.fromForm(@form)
    else
      @item = new Author().fromForm(@form)

    # Construct the links list object
    links = []
    @linksList.find('.link-form').each ->
      label = $.trim $(@).find('input[name=link_label]').val()
      url = $.trim $(@).find('input[name=link_url]').val()
      code = $.trim $(@).find('input[name=link_code]').val()
      if label and url
        links.push label: label, url: url, code: code
    @item.links = links
    
    # Save the item and make sure it validates
    if @item.save()
      @back()
    else
      msg = @item.validate()
      @showError msg

    return @

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
    @navigate('/authors/list')

  preventSubmit: (e) ->
    e.preventDefault()
    return false
    
  deactivate: ->
    @el.scrollTop(0)
    super


class AuthorList extends Spine.Controller
  className: 'author list panel fixed-header'

  events:
    'click h1 .count':    'reload'

  constructor: ->
    super
    # @active @render
    Author.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      authors: Author.filter(@filterObj).sort(Author.nameSort)
    @html templates.render('authors.html', {}, context)

  filter: (@filterObj) =>
    @render()
    @el.scrollTop(0)

  reload: ->
    Author.fetch()


class Authors extends Spine.Stack
  className: 'authors panel'

  controllers:
    list: AuthorList
    form: AuthorForm

  default: 'list'

  routes:
    '/authors/list': 'list'
    '/author/new':   'form'
    '/author/:id':   'form'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Authors