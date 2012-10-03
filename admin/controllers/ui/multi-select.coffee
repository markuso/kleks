Spine     = require('spine/core')
$         = Spine.$

class MultiSelectUI extends Spine.Controller
  tag: 'ul'
  className: 'ui-multi-select'
  tagClass: ''
  itemTag: 'li'
  itemClass: '' 
  items: []
  selectedItems: []
  keyField: 'id'
  nameField: 'name'
  valueField: 'id'
  valueFields: null
  emptyText: 'Nothing to select here.'
  jumpToFirst: true

  constructor: ->
    super
    @el.addClass(@tagClass) if @tagClass
    @render()

  render: =>
    @el.html $("<#{@itemTag}/>").html(@emptyText) unless @items

    # create and render all options in the list
    for item in @items
      # create a list option item
      $option = $("<#{@itemTag}/>")
      $option.html item[@nameField]
      $option.attr("data-#{@keyField}", item[@keyField])
      if @valueFields
        for field in @valueFields
          $option.attr("data-#{field}", item[field])
      else
        $option.attr("data-#{@valueField}", item[@valueField])
      
      # add some needed classes
      $option.addClass(@itemClass) if @itemClass
      $option.addClass('selected') if item[@keyField] in @selectedItems

      # setup a selection toggle
      $option.on 'click', (e) ->
        e.preventDefault()
        $(@).toggleClass('selected')
      
      # add the created option to the list
      @el.append $option

    @delay(@scrollToSelected, 1000) if @jumpToFirst
    @

  selected: =>
    cls = @
    items = []
    @el.children('.selected').each ->
      $option = $(@)
      if cls.valueFields
        obj = {}
        for field in cls.valueFields
          obj[field] = $option.attr("data-#{field}")
        items.push obj
      else
        items.push $option.attr("data-#{cls.valueField}")
    return items

  scrollToSelected: =>
    position = @el.find('.selected:first')?.position()
    @el.scrollTop(position?.top - 12) if position


module.exports = MultiSelectUI