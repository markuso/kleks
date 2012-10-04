# Bunch of utility functions
settings   = require('settings/root')

exports.msg = {
  DATE_NOT_VALID: "Date format is wrong. Use this format: 'Feb 20 2012 6:30 PM'"
}

exports.cleanCode = (code) ->
  code.toLowerCase().replace(/[\ \.\'\"\:\,\-]/g, '_')

exports.cleanSlug = (slug) ->
  slug.toLowerCase().replace(/[\ \.\'\"\:\,]/g, '-')

exports.cleanContent = (content) ->
  protocol = "http(s)?:\/\/"
  if settings.app.dev_host
    dev_host = new RegExp(protocol+settings.app.dev_host, "g")
    content = content.replace(dev_host, '')
  if settings.app.prod_host
    prod_host = new RegExp(protocol+settings.app.prod_host, "g")
    content = content.replace(prod_host, '')
  return content
