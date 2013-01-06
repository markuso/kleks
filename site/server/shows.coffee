templates = require("duality/templates") 

exports.not_found = (doc, req) ->
  code: 404
  title: "404 Not Found"
  content: templates.render("404.html", req, { host: req.headers.Host })

exports.redirect = (doc, req) ->
  if doc
    code: 301
    headers: { 'Location': doc.location }
  else
    code: 404
    title: "404 Not Found"
    content: templates.render("404.html", req, { host: req.headers.Host })

exports.moved = (doc, req) ->
  code: 301
  headers: { 'Location': req.query.loc }

exports.moved_pattern = (doc, req) ->
  loc = req.query.loc
  switch req.query.site
    when 'www.evitaochel.com'
      type = 'essay'
    else
      type = 'essay'
  loc = loc.replace(/\:type/g, type)
  loc = loc.replace(/\:slug/g, req.query.slug)
  loc = loc.replace(/\:id/g, req.query.id)
  return {
    code: 301
    headers: { 'Location': loc }
  }