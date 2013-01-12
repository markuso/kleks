moment    = require('lib/moment')

exports.isDev = (req) ->
  # We are on DEV when Host has string like
  # 'dev.' or 'staging.' or '.local' or '.dev' or 'localhost'
  re = /(^dev\.|^staging\.|\.local$|\.dev$|localhost)/
  return re.test(req.headers.Host)

exports.prettyDate = (date) ->
  moment.utc(date).local().format('MMM Do YYYY')

exports.halfDate = (date) ->
  moment.utc(date).local().format('MMM D')

exports.isItFresh = (date) ->
  if moment.utc().eod() < moment.utc(date).add('days', 30).eod()
    return true
  return false

exports.capitalize = (str) ->
  str ?= ''
  str.charAt(0).toUpperCase() + str.slice(1)