Spine     = require('spine/core')
$         = Spine.$
base64    = require('base64')


class FileUploadUI extends Spine.Controller
  tag: 'div'
  className: 'ui-file-upload'
  fieldName: 'file_upload'
  selectedFieldName: 'photo'
  dropzoneText: 'drop or click'
  attachments: {}
  docId: null
  selectedFile: null

  events:
    'click ul.files-list > li':   'itemClick'
    'dblclick ul.files-list > li': 'itemDblClick'

  constructor: ->
    super
    @render()

  render: ->
    @dropzone = $("<div class=\"dropzone\">#{@dropzoneText}</div>")
    @fileInput = $("<input type=\"file\" name=\"#{@fieldName}\" style=\"display: none;\">")
    @fileSelectedInput = $("<input type=\"hidden\" name=\"#{@selectedFieldName}\">")
    @fileName = $("<div class=\"filename\"/>")
    @filesList = $("<ul class=\"files-list\"/>")
    @el.append @dropzone, @fileInput, @fileSelectedInput, @fileName, @filesList
    @setupList()
    @setupZoneEvents()

  setupList: ->
    names = (prop for prop of @attachments)
    for name in names
      file = @attachments[name]
      @addToList(name, file.content_type)

    if @selectedFile
      item = @filesList.find("> li[data-filename='#{@selectedFile}']")
      @selectItem(item) if item
    
  addToList: (name, type, dataURL = null) =>
    $item = $('<li/>')
    url = if @docId then "/file/#{@docId}/#{name}" else ''
    
    $item.attr('data-filename', name)
         .attr('data-url', url)
    if type.match(/image.*/)
      $img = $('<img>')
      if dataURL
        $img.attr('src', dataURL)
      else if @docId
        $img.attr('src', url)
      $item.append $img
    else
      $item.append $("<div><em>#{type}</em><br>#{name}</div>")

    @filesList.append $item
    
    # Also select the item if it is the only one
    @selectItem($item) if @attachments.length is 1

  itemClick: (e) ->
    # Selecting the main photo
    e.preventDefault()
    e.stopPropagation()
    item = e.currentTarget
    if $(item).hasClass('selected')
      @resetSelection('Nothing is selected')
    else
      @selectItem(item)

  itemDblClick: (e) ->
    # Removing an attachment
    e.preventDefault()
    e.stopPropagation()
    @resetSelection()
    @removeItem(e.currentTarget)

  selectItem: (item) =>
    @resetSelection()
    if item
      name = $(item).attr('data-filename')
      $(item).addClass('selected')
      @fileName.html "Selected: #{name}"
      @fileSelectedInput.val(name)

  resetSelection: (msg = '') ->
    @filesList.children().removeClass('selected')
    @fileName.html msg
    @fileSelectedInput.val('')

  removeItem: (item) =>
    if item
      name = $(item).attr('data-filename')
      if confirm "Remove this attachment?\n#{name}"
        delete @attachments[name]
        $(item).remove()
        @fileSelectedInput.val('') if @fileSelectedInput.val() is name
        @fileName.html "#{name} was removed"

  setupZoneEvents: ->
    @dropzone.on 'dragenter dragover', (e) ->
      e.originalEvent.preventDefault()
      e.originalEvent.stopPropagation()
      e.originalEvent.dataTransfer.dropEffect = 'copy'

    @dropzone.on 'drop', (e) =>
      e.originalEvent.preventDefault()
      e.originalEvent.stopPropagation()
      @addFiles e.originalEvent.dataTransfer.files

    @dropzone.on 'click', (e) =>
      e.preventDefault()
      @fileInput.click()

    @fileInput.on 'change', (e) =>
      @addFiles e.target.files

  addFiles: (files) =>
    if files.length
      file = files[0]
      name = file.name.replace(/[\ \'\"]/g,'-')
      name = encodeURIComponent(name)
      type = file.type
      reader = new FileReader
      
      reader.addEventListener 'load', (e) =>
        dataURL = e.target.result
        # Since the result is a data URL and already base64 encoded
        # then just remove the first meta info and we get the file
        # data the we need to save into _attachments in CouchDB
        result = dataURL.replace(/^data:.*;base64,/, '')
        @attachments[name] =
          content_type: type
          data: result
        @addToList(name, type, dataURL)
        @fileName.html name
      
      reader.addEventListener 'loadstart', (e) =>
        @fileName.html "In progress"

      reader.addEventListener 'progress', (e) =>
        @fileName.html @fileName.html() + "."
      
      reader.addEventListener 'error', (e) =>
        @fileName.html "Couldn't load the file."
      
      reader.readAsDataURL file


module.exports = FileUploadUI