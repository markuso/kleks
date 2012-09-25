templates = require("duality/templates") 

exports.index = (doc, req) ->
  title: "Kleks Admin"
  content: templates.render("index.html", req, {})

exports.not_found = (doc, req) ->
  title: "404 Not Found"
  content: templates.render("404.html", req, {})

exports.colors = (doc, req) ->
  title: "Color Samples"
  content: templates.render("colors.html", req, {
    colors: ['#9EDFB5', '#DFA57C', '#E6BC7E', '#D5D298', '#98D5A7', '#98D5BA', '#61CDDB', '#8FB1DD', '#A8B5E7', '#AF9EDA', '#DA9EC7', '#DA9EAF', '#DA9EA1', '#DAA39E', '#DAAF9E', '#DABB9E', '#DAC79E', '#A5DA9E', '#9EDAB1', '#9EC4DA', '#B6B4EB', '#DD9DAC', '#BAA8E6', '#B5E6A8', '#E6D4A8', '#E6CBA8', '#E6B7A8']
  })