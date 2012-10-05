Spine       = require('spine/core')
$           = Spine.$
Showdown    = require('showdown')


class PreviewUI extends Spine.Controller
  tag: 'div'
  className: 'ui-preview'
  live: true
  showClose: true

  events:
    'click .close-button':    'close'

  constructor: (@field) ->
    super
    @field = $(@field) if typeof @field is String
    @inner = $('<div class="inner" />')
    @append @inner

    @md = new Showdown.converter()
    
    @render()
    @setupLivePreview() if @live
    @setupCloseButton() if @showClose
    @

  render: ->
    contentHtml = @md.makeHtml(@field.val())
    @inner.html contentHtml
  
  setupLivePreview: ->
    @field.on 'keyup', (e) =>
      @render()

  setupCloseButton: ->
    @append $('<a class="close-button button small">x</a>')

  close: (e) ->
    e?.preventDefault()
    @release()


module.exports = PreviewUI