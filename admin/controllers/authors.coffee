Spine       = require('spine/core')
# $           = Spine.$
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
    'select[name=links]':      'formLinks'
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
        @title = 'Copy Author'
        @item = Author.find(params.id.split('-')[1]).dup()
      else
        @item = Author.find(params.id)
        @title = @item.name
    else
      @title = 'New Author'
      @item = {}
    
    @item.sites = Site.all().sort(Site.nameSort)
    @html templates.render('author-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formSite.val(@item.site)
      @formLinks.val(JSON.stringify(@item.links))
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
    if @editing
      @item.fromForm(@form)
    else
      @item = new Author().fromForm(@form)

    # Transform some fields before saving
    @item.links = JSON.parse(@item.links)
    
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
    @navigate('/authors/list')

  preventSubmit: (e) ->
    e.preventDefault
    
  deactivate: ->
    super
    @el.scrollTop(0, 0)


class AuthorList extends Spine.Controller
  className: 'author list panel'

  constructor: ->
    super
    # @active @render
    Author.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      authors: Author.filter(@filterObj).sort(Author.nameSort)
    @el.html templates.render('authors.html', {}, context)
    @

  filter: (@filterObj) =>
    @render()


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


module.exports = Authors