settings  = require('settings/root')

exports.docs = (head, req) ->
  start code: 200, headers: {'Content-Type': 'application/json'}

  rows = []
  typesToReduceLoad = ['block','collection','author','sponsor']
  typesToReduceLoad = typesToReduceLoad.concat(settings.app.content_types)

  while row = getRow()
    doc = row.doc

    # Remove some data that is not needed for list
    # views to reduce the amount of data download
    if doc.type in typesToReduceLoad
      delete doc.intro
      delete doc.body
      delete doc.content
      delete doc.bio

    rows.push({id: doc._id, doc: doc})

  return JSON.stringify({ count: rows.length, rows: rows })
