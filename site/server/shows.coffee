templates = require("duality/templates") 

exports.not_found = (doc, req) ->
  code: 404
  title: "404 Not Found"
  content: templates.render("404.html", req, { host: req.headers.Host })

exports.moved = (doc, req) ->
  code: 301
  headers: { location: req.query.loc }