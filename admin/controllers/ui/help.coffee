Spine       = require('spine/core')
$           = Spine.$
templates   = require('duality/templates')


class HelpUI extends Spine.Controller
  tag: 'div'
  className: 'ui-help'

  events:
    'click .close-button':    'close'

  constructor: ->
    super
    @render()
    @hide()
    @hookButtons()

  render: ->
    @html templates.render('help.html', {}, {})

  show: ->
    @el.show()

  hide: ->
    @el.hide()

  close: (e) ->
    e?.preventDefault()
    @hide()
  
  hookButtons: ->
    $('body').on 'click', '.markdown-help', (e) =>
      e?.preventDefault()
      @el.toggle()


module.exports = HelpUI