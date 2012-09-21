exports.docs_by_site =
  map: (doc) ->
    if doc.site and doc.type
      emit [doc.site, doc.type, doc._id], doc.title or doc.name
    else if doc.type
      emit ['global', doc.type, doc._id], doc.title or doc.name
    else
      emit ['global', '_doc_', doc._id], doc.title or doc.name
  reduce: (key, values, rereduce) ->
    key.length

exports.docs_by_type =
  map: (doc) ->
    if doc.type
      emit [doc.type, doc._id], doc.title or doc.name
