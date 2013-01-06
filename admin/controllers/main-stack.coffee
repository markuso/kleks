Spine       = require('spine/core')

Dashboard   = require('controllers/dashboard')
Sites       = require('controllers/sites')
Authors     = require('controllers/authors')
Collections = require('controllers/collections')
Essays      = require('controllers/essays')
Videos      = require('controllers/videos')
Scenes      = require('controllers/scenes')
Blocks      = require('controllers/blocks')
Contacts    = require('controllers/contacts')
Sponsors    = require('controllers/sponsors')
Redirects   = require('controllers/redirects')

FilterBox   = require('controllers/filter-box')


class MainStack extends Spine.Stack
  className: 'main stack'

  controllers:
    dashboard:   Dashboard
    sites:       Sites
    authors:     Authors
    collections: Collections
    essays:      Essays
    videos:      Videos
    scenes:      Scenes
    blocks:      Blocks
    contacts:    Contacts
    sponsors:    Sponsors
    redirects:   Redirects

  default: 'dashboard'

  routes:
    '/':            'dashboard'
    '/sites':       'sites'
    '/authors':     'authors'
    '/collections': 'collections'
    '/essays':      'essays'
    '/videos':      'videos'
    '/scenes':      'scenes'
    '/blocks':      'blocks'
    '/contacts':    'contacts'
    '/sponsors':    'sponsors'
    '/redirects':   'redirects'

  constructor: ->
    super
    @filterBox = new FilterBox
    @append @filterBox

    # ..also see `hookPanelsToNav()` in index.coffee


module.exports = MainStack
    