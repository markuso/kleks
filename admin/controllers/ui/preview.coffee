Spine       = require('spine/core')
$           = Spine.$
Showdown    = require('showdown')
{_}         = require("underscore")


class PreviewUI extends Spine.Controller
  tag: 'div'
  className: 'ui-preview'
  filed: null
  live: true
  showClose: true
  autoOpen: true

  events:
    'click .close-button':    'close'
    'click .preview-button':  'render'

  constructor: ->
    super
    if @field
      @field = $(@field) if typeof @field is String
      @inner = $('<div class="inner" />')
      @el.append @inner

      @md = new Showdown.converter()
      
      @render()
      @setupLivePreview() if @live
      @setupPreviewButton() unless @live
      @setupCloseButton() if @showClose
      @open() if @autoOpen
      @

  render: (e) =>
    contentHtml = @md.makeHtml(@field.val())
    @inner.html contentHtml
  
  setupLivePreview: =>
    # Wait before firing the event constantly (a way to throttle)
    @lazyRender = _.debounce(@render, 800)
    @field.on 'keyup', @lazyRender

  setupCloseButton: ->
    @el.append $('<a class="close-button button small">X</a>')

  setupPreviewButton: ->
    @el.append $('<a class="preview-button button small">Render</a>')

  open: (e) =>
    e?.preventDefault()
    # Add to parent form
    @parentForm = @field.parents('form')
    @parentForm.append @el
    @parentForm.addClass('preview-mode')

  close: (e) =>
    e?.preventDefault()
    @parentForm.removeClass('preview-mode')
    @field.off 'keyup', @lazyRender
    @release()


module.exports = PreviewUI