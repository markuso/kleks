Spine       = require('spine/core')

Sites       = require('controllers/sites')
Authors     = require('controllers/authors')
# Collections = require('controllers/collections')
# Essays      = require('controllers/essays')
# Blocks      = require('controllers/blocks')
# Sponsors    = require('controllers/sponsors')
# Contacts    = require('controllers/contacts')


class MainStack extends Spine.Stack
  className: 'main stack'

  controllers:
    sites: Sites
    authors: Authors

  default: 'sites'

  routes:
    '/sites':   'sites'
    '/authors': 'authors'


module.exports = MainStack
    