Spine     = require('spine/core')
$         = Spine.$
base64    = require('base64')


class FileUploadUI extends Spine.Controller
  tag: 'div'
  className: 'ui-file-upload'
  fieldName: 'file_upload'
  dropzoneText: 'drop or click'
  attachments: {}
  docId: null

  constructor: ->
    super
    @render()

  render: ->
    @dropzone = $("<div class=\"dropzone\">#{@dropzoneText}</div>")
    @fileInput = $("<input type=\"file\" name=\"#{@fieldName}\" style=\"display: none;\"/>")
    @fileName = $("<div class=\"filename\"/>")
    @filesList = $("<ul class=\"list\"/>")
    @el.append @dropzone, @fileInput, @fileName, @filesList
    @setupList()
    @setupEvents()

  setupList: ->
    if @docId
      names = (prop for prop of @attachments)
      for name in names
        file = @attachments[name]
        @filesList.append "<li><img src=\"/file/#{@docId}/#{name}\"></li>"

  setupEvents: ->
    @dropzone.on 'dragenter dragover', (e) ->
      e.originalEvent.preventDefault()
      e.originalEvent.stopPropagation()
      e.originalEvent.dataTransfer.dropEffect = 'copy'

    @dropzone.on 'drop', (e) =>
      e.originalEvent.preventDefault()
      e.originalEvent.stopPropagation()
      @prepareFiles e.originalEvent.dataTransfer.files

    @dropzone.on 'click', (e) =>
      e.preventDefault()
      @fileInput.click()

    @fileInput.on 'change', (e) =>
      @prepareFiles e.target.files

  prepareFiles: (files) =>
    if files.length
      file = files[0]
      name = encodeURIComponent(file.name)
      type = file.type
      reader = new FileReader
      
      reader.addEventListener 'load', (e) =>
        dataURL = e.target.result
        # Since the result is a data URL and already base64 encoded
        # then just remove the first meta info and we get the file
        # data the we need to save into _attachments in CouchDB
        result = dataURL.replace(/^data:.*;base64,/, "")
        @attachments[name] =
          content_type: type
          data: result
        @fileName.html "#{name}"
      
      reader.addEventListener 'loadstart', (e) => return

      reader.addEventListener 'progress', (e) => return
      
      reader.addEventListener 'error', (e) => return
      
      reader.readAsDataURL file


module.exports = FileUploadUI