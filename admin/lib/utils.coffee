# Bunch of utility functions

settings    = require('settings/root')

exports.cleanCode = (code) ->
  code.toLowerCase().replace(/[\ \.\'\"\-]/g, '_')

exports.cleanSlug = (slug) ->
  slug.toLowerCase().replace(/[\ \.\'\"]/g, '-')

exports.cleanContent = (content) ->
  dev_host = settings.app.dev_host
  prod_host = settings.app.prod_host
  content.replace(/\http(s)?:\/\/admin.kleks.local/g, '')
