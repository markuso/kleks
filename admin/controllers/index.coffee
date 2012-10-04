Spine       = require('spine/core')
require('spine/route')
require('spine/manager')
require('lib/fastclick')

templates   = require('duality/templates')
session     = require('session')

MainNav     = require('controllers/main-nav')
MainStack   = require('controllers/main-stack')
HelpUI      = require('controllers/ui/help')

Site        = require('models/site')
Author      = require('models/author')
Collection  = require('models/collection')
Essay       = require('models/essay')
Scene       = require('models/scene')
Block       = require('models/block')
Contact     = require('models/contact')
Sponsor     = require('models/sponsor')


class App extends Spine.Controller
  
  constructor: ->
    super    
    @checkSession()

  checkSession: ->
    session.info (err, info) =>
      if 'manager' in info.userCtx.roles
        @startApp()
      else
        username = 'evita'
        pass = 'n3wst@rt'
        session.login username, pass, (err, resp) =>
          if err
            alert "Error logging in as #{username}: #{err}"
          else
            if 'manager' in resp.roles
              @startApp()
            else
              alert "User #{username} does not have permission"

  startApp: ->
    # Load data models
    Site.fetch()
    Author.fetch()
    Collection.fetch()
    Essay.fetch()
    Scene.fetch()
    Block.fetch()
    Contact.fetch()
    Sponsor.fetch()

    @mainNav   = new MainNav
    @mainStack = new MainStack
    @helpUI    = new HelpUI

    @append @mainNav, @mainStack, @helpUI

    Spine.Route.setup()

    @doOtherStuff()

  doOtherStuff: ->
    # Use the fastclick module for touch devices.
    # Add a class of `needsclick` of the original click
    # is needed.
    new FastClick(document.body)


module.exports = App
    