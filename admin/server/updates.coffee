{_}   = require('underscore')

exports.spine_adapter_model = (doc, req) ->
  if req.method is 'POST'    
    create(doc, req)
  else if req.method is 'PUT'
    update(doc, req)
  else if req.method is 'DELETE'
    destroy(doc, req)

create = (doc, req) ->
  doc = JSON.parse(req.body)
  doc.type = req.query.type
  doc._id = req.uuid unless doc._id
  resp =
    ok: yes
    body: JSON.stringify(doc)
  [doc, resp]

update = (doc, req) ->
  delete doc._revisions
  new_fields = JSON.parse(req.body)
  delete new_fields.id
  updated_doc = _.defaults(new_fields, doc)
  resp =
    ok: yes
    body: JSON.stringify(updated_doc)
  [updated_doc, resp]

destroy = (doc, req) ->
  doc._deleted = yes
  resp =
    ok: yes
    body: JSON.stringify({})
  [doc, resp]
