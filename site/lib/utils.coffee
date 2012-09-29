moment    = require('lib/moment')

exports.prettyDate = (date) ->
  moment.utc(date).local().format('MMM Do YYYY')

exports.isItFresh = (date) ->
  if moment.utc().eod() < moment.utc(date).add('days', 30).eod()
    return true
  return false
