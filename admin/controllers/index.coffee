Spine       = require('spine/core')
require('spine/route')
require('spine/manager')

templates   = require('duality/templates')
session     = require('session')

MainNav     = require('controllers/main-nav')
MainStack   = require('controllers/main-stack')

Site        = require('models/site')
Author      = require('models/author')
Collection  = require('models/collection')
Essay       = require('models/essay')
Block       = require('models/block')
Contact     = require('models/contact')
Sponsor     = require('models/sponsor')


class App extends Spine.Controller
  
  constructor: ->
    super
    @checkSession()

  checkSession: ->
    session.info (err, info) =>
      if '_admin' in info.userCtx.roles
        @startApp()
      else
        username = 'admin'
        pass = 'couchaxs'
        session.login username, pass, (err, resp) =>
          if err
            alert "Error logging in as #{username}: #{err}"
          else
            if '_admin' in resp.roles
              @startApp()
            else
              alert "User #{username} does not have permission"

  startApp: ->
    # Load data models
    Site.fetch()
    Author.fetch()
    Collection.fetch()
    Essay.fetch()
    Block.fetch()
    Contact.fetch()
    Sponsor.fetch()

    @mainNav   = new MainNav
    @mainStack = new MainStack

    @append @mainNav, @mainStack

    Spine.Route.setup()


module.exports = App
    