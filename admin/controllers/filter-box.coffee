Spine       = require('spine/core')
$           = Spine.$
templates   = require('duality/templates')

Site        = require('models/site')

KEYCODE_ENTER = 13
KEYCODE_ESC   = 27


class FilterBox extends Spine.Controller
  className: 'filter-box'

  constructor: ->
    super
    @siteId = ''
    @query = ''
    Site.bind 'change refresh', @render

  render: =>
    context = 
      sites: Site.all()
    @el.html templates.render('filter-box.html', {}, context)
    @setup()
    @

  setup: ->
    @filterInput = $(@el).find('input.filter-input')
    @filterClear = $(@el).find('.clear-filter')
    @selectedSite = $(@el).find('.selected-site')
    @siteSelector = $(@el).find('ul.site-selector')
    
    @filterInput.on 'keyup', (e) =>
      if e.keyCode is KEYCODE_ESC
        @clear()
      else if e.keyCode is KEYCODE_ENTER
        @filter()
      else
        @filter()

    @filterClear.on 'click', (e) =>
      @clear()
    
    @selectedSite.on 'click', (e) =>
      @siteSelector.toggle()
    
    @siteSelector.find('li').on 'click', (e) =>
      $item = $(e.currentTarget)
      @selectedSite.find('> span').html($item.html()).attr('class', $item.attr('class'))
      @siteId = $item.attr('data-id')
      @siteSelector
        .hide()
        .scrollTop(0, 0)
        .children()
        .removeClass('selected')
      $item.addClass('selected')
      @filter()

  clear: ->
    @filterInput.val('')
    @filter()

  filter: =>
    @query = $.trim(@filterInput.val())
    if @query
      @filterClear.addClass('active')
    else
      @filterClear.removeClass('active')
    Spine.trigger 'filterbox:change',
      query: @query
      siteId: @siteId


module.exports = FilterBox