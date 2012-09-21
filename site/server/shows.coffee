templates = require("duality/templates") 

exports.not_found = (doc, req) ->
  title: "404 Not Found"
  content: templates.render("404.html", req, {})

exports.moved = (doc, req) ->
  code: 301
  headers: { location: req.query.loc }