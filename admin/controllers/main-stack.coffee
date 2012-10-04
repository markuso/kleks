Spine       = require('spine/core')

Dashboard   = require('controllers/dashboard')
Sites       = require('controllers/sites')
Authors     = require('controllers/authors')
Collections = require('controllers/collections')
Essays      = require('controllers/essays')
Scenes      = require('controllers/scenes')
Blocks      = require('controllers/blocks')
Contacts    = require('controllers/contacts')
Sponsors    = require('controllers/sponsors')

FilterBox   = require('controllers/filter-box')


class MainStack extends Spine.Stack
  className: 'main stack'

  controllers:
    dashboard:   Dashboard
    sites:       Sites
    authors:     Authors
    collections: Collections
    essays:      Essays
    scenes:      Scenes
    blocks:      Blocks
    contacts:    Contacts
    sponsors:    Sponsors

  default: 'dashboard'

  routes:
    '/':            'dashboard'
    '/sites':       'sites'
    '/authors':     'authors'
    '/collections': 'collections'
    '/essays':      'essays'
    '/scenes':      'scenes'
    '/blocks':      'blocks'
    '/contacts':    'contacts'
    '/sponsors':    'sponsors'

  constructor: ->
    super
    @filterBox = new FilterBox
    @append @filterBox


module.exports = MainStack
    