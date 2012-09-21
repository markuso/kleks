templates = require("duality/templates") 

exports.index = (doc, req) ->
  title: "Kleks Admin"
  content: templates.render("index.html", req, {})

exports.not_found = (doc, req) ->
  title: "404 Not Found"
  content: templates.render("404.html", req, {})