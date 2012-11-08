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
    @mainNav = new MainNav
    @append @mainNav
    @initApp()

  setupSession: ->
    session.on 'change', @checkRole
    
    session.info (err, info) =>
      @checkRole info.userCtx

  checkRole: (userCtx) =>
    if 'manager' in userCtx.roles
      @mainNav.hideLogin()
      @startApp() unless @appStarted
      @loadData() unless @dataLoaded
    else
      @mainNav.showLogin()
      @unloadData() if @dataLoaded
      @endApp() if @appStarted

  initApp: =>
    @setupSession()

    @mainStack = new MainStack
    @helpUI    = new HelpUI
    Spine.Route.setup()

    @hookPanelsToNav()
    @doOtherStuff()

  startApp: =>
    @loadData() unless @dataLoaded
    unless @appStarted
      @append @mainStack, @helpUI
      @navigate('/')
      @appStarted = true

  endApp: =>
    if @appStarted
      @mainStack.el.remove()
      @helpUI.el.remove()
      @appStarted = false

  loadData: =>
    # Load data models
    Site.fetch()
    Author.fetch()
    Collection.fetch()
    Essay.fetch()
    Scene.fetch()
    Block.fetch()
    Contact.fetch()
    Sponsor.fetch()
    @dataLoaded = true

  unloadData: =>
    # Empty data from client models
    Site.deleteAll()
    Author.deleteAll()
    Collection.deleteAll()
    Essay.deleteAll()
    Scene.deleteAll()
    Block.deleteAll()
    Contact.deleteAll()
    Sponsor.deleteAll()
    @dataLoaded = false

  hookPanelsToNav: ->
    cls = @
    for k, v of @mainStack.controllers
      @mainStack[k].active -> cls.mainNav.selectFromClassName(@className)

  doOtherStuff: ->
    # Use the fastclick module for touch devices.
    # Add a class of `needsclick` of the original click
    # is needed.
    new FastClick(document.body)


module.exports = App
    