Spine       = require('spine/core')
$           = Spine.$
templates   = require('duality/templates')
utils       = require('lib/utils')

# For importing HTML from old sites
require('lib/reMarked')
require('lib/jquery-xdomainajax')

MultiSelectUI = require('controllers/ui/multi-select')
FileUploadUI  = require('controllers/ui/file-upload')

Scene       = require('models/scene')
Author      = require('models/author')
Collection  = require('models/collection')
Sponsor     = require('models/sponsor')
Site        = require('models/site')


class SceneForm extends Spine.Controller
  className: 'scene form panel'

  elements:
    '.item-title':             'itemTitle'
    '.error-message':          'errorMessage'
    'form':                    'form'
    'select[name=site]':       'formSite'
    'select[name=author_id]':  'formAuthorId'
    'select[name=sponsor_id]': 'formSponsorId'
    'input[name=title]':       'formTitle'
    'input[name=published]':   'formPublished'
    'textarea[name=body]':     'formBody'
    '.collections-list':       'collectionsList'
    '.upload-ui':              'fileUploadContainer'
    '.save-button':            'saveButton'
    '.cancel-button':          'cancelButton'
    'button.fullscreen-button': 'fullscreenButton'

  events:
    'submit form':              'preventSubmit'
    'click .save-button':       'save'
    'click .cancel-button':     'cancel'
    'click .delete-button':     'destroy'
    'change select[name=site]': 'siteChange'
    'blur input[name=slug]':    'updateSlug'
    'click .fullscreen-button': 'fullscreen'
    'click .import-button':     'import'

  constructor: ->
    super
    @active @render

  render: (params) ->
    @editing = params.id?
    if @editing
      @copying = params.id.split('-')[0] is 'copy'
      if @copying
        @title = 'Copy Scene'
        @item = Scene.find(params.id.split('-')[1]).dup()
      else
        @item = Scene.find(params.id)
        @title = @item.name
    else
      @title = 'New Scene'
      @item = {}

    @item.collections ?= []
    @item._attachments ?= {}
    
    @item.sites = Site.all().sort(Site.nameSort)
    @item.sponsors = Sponsor.all().sort(Sponsor.nameSort)
    @html templates.render('scene-form.html', {}, @item)

    @itemTitle.html @title
    
    # Set few initial form values
    if @editing
      @formSite.val(@item.site)
      @formSponsorId.val(@item.sponsor_id)
      @formPublished.prop('checked', @item.published)
    else
      @formSite.val(@stack.stack.filterBox.siteId)
      # @formPublished.prop('checked', true)
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
      @makeAuthorsList(site)
      @makeCollectionsList(site)
    else
      $siteSelected.html ""

  makeAuthorsList: (site) ->
    authors = Author.findAllByAttribute('site', site.id).sort(Author.nameSort)
    @formAuthorId.empty()
      .append "<option value=\"\">Select an author...</option>"
    for author in authors
      @formAuthorId.append "<option value=\"#{author.id}\">#{author.name}</option>"
    @formAuthorId.val(@item.author_id)
  
  makeCollectionsList: (site) ->
    collections = Collection.findAllByAttribute('site', site.id).sort(Collection.nameSort)
    @collectionSelectUI = new MultiSelectUI
      items: collections
      selectedItems: (c.id for c in @item.collections)
      valueFields: ['id','slug']
    @collectionsList.html @collectionSelectUI.el

  updateSlug: (e) =>
    slug = $(e.currentTarget)
    unless slug.val()
      slug.val utils.cleanSlug(@formTitle.val())

  fullscreen: (e) =>
    e?.preventDefault()
    @fullscreenButtonText ?= @fullscreenButton.html()
    if @form.hasClass('fullscreen')
      @form.removeClass('fullscreen')
      @fullscreenButton.html @fullscreenButtonText
    else
      @form.addClass('fullscreen')
      @fullscreenButton.html "&lt; Exit #{@fullscreenButtonText}"

  import: (e) =>
    # For importing old HTML to Markdown directly from old location
    e?.preventDefault()
    url = $.trim prompt("Paste a URL from #{@formSite.val()}", @item.old_url or '')
    if url
      $.ajax
        type: 'GET'
        url: url
        success: (res) =>
          $html = $(res.responseText)
          $title = $html.find('.post > h2:first > a')
          $author = $html.find('.post .entry-author > a:first')
          $date = $html.find('.post .entry-date > .published')
          $content = $html.find('.post .entry:first')
          $image = $content.find('img:first')
          if $content
            $content.find('.addthis_toolbox, .author-bio').remove()
            options =
                link_list:  false    # render links as references, create link list as appendix
                h1_setext:  true     # underline h1 headers
                h2_setext:  true     # underline h2 headers
                h_atx_suf:  true     # header suffixes (###)
                gfm_code:   false    # render code blocks as via ``` delims
                li_bullet:  "*"      # list item bullet style
                hr_char:    "-"      # hr style
                indnt_str:  "    "   # indentation string
                bold_char:  "*"      # char used for strong
                emph_char:  "_"      # char used for em
                gfm_tbls:   false    # markdown-extra tables
                tbl_edges:  false    # show side edges on tables
                hash_lnks:  false    # anchors w/hash hrefs as links
            reMarker = new reMarked(options)
            markdown = reMarker.render($content.html())
            @formBody.val(markdown)
            
          if not @item.old_url
            @formTitle.val($title.text()) if $title
            $slug = @form.find('input[name=slug]')
            unless slug.val()
              $slug.val($title.attr('href').replace('www.', '').replace("http://#{@formSite.val().replace('www.', '')}", '')) if $title
            @formAuthorId.val($author.text()) if $author
            @form.find('input[name=published_at]').val($date.text()) if $date

  save: (e) ->
    e.preventDefault()
    if @editing
      @item.fromForm(@form)
    else
      @item = new Scene().fromForm(@form)

    @item.collections = @collectionSelectUI.selected()
    @item._attachments = @fileUploadUI.attachments

    # Take care of some boolean checkboxes
    @item.published = @formPublished.is(':checked')
    
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
    @navigate('/scenes/list')

  preventSubmit: (e) ->
    e.preventDefault()
    
  deactivate: ->
    @el.scrollTop(0, 0)
    super


class SceneList extends Spine.Controller
  className: 'scene list panel'

  constructor: ->
    super
    # @active @render
    Scene.bind 'change refresh', @render
    Spine.bind 'filterbox:change', @filter

  render: =>
    context = 
      scenes: Scene.filter(@filterObj).sort(Scene.titleSort)
    @html templates.render('scenes.html', {}, context)

  filter: (@filterObj) =>
    @render()
    @el.scrollTop(0, 0)


class Scenes extends Spine.Stack
  className: 'scenes panel'

  controllers:
    list: SceneList
    form: SceneForm

  default: 'list'

  routes:
    '/scenes/list': 'list'
    '/scene/new':   'form'
    '/scene/:id':   'form'

  constructor: ->
    super
    for k, v of @controllers
      @[k].active => @active()


module.exports = Scenes