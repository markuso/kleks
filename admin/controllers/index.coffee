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

  initApp: =>
    @setupSession()

    @mainStack = new MainStack
    @helpUI    = new HelpUI
    Spine.Route.setup()
    @navigate('/')

    @hookPanelsToNav()
    @setupOnlineOffline()
    @doOtherStuff()

  setupSession: ->
    session.on 'change', @checkRole
    $(window).on 'focus', @getSessionInfo
    # @mainNav.bind 'beforeChange', @getSessionInfo
    @getSessionInfo()

  getSessionInfo: =>
    session.info (err, info) =>
      @checkRole info.userCtx

  checkRole: (userCtx) =>
    if 'manager' in userCtx.roles
      @mainNav.hideLogin()
      @startApp() unless @appStarted
      @loadData() unless @dataLoaded
      @mainNav.greetUser(userCtx.name)
    else
      @mainNav.showLogin()
      @unloadData() if @dataLoaded
      @endApp() if @appStarted

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

  setupOnlineOffline: ->   
    if not navigator.onLine
      @mainNav.offline.show(500)
      Spine.trigger 'app:offline'
      
    $(window).on 'offline', =>
      @mainNav.offline.show(500)
      Spine.trigger 'app:offline'
    
    $(window).on 'online', =>
      @mainNav.offline.hide()
      Spine.trigger 'app:online'

  doOtherStuff: ->
    # Use the fastclick module for touch devices.
    # Add a class of `needsclick` if the original click
    # is needed.
    new FastClick(document.body)

    # Alert user when leaving the application.
    window.onbeforeunload = (e) ->
      msg = 'Leaving Kleks now, but you may have unsaved items. Keep going if you are sure.'
      e = window.event if not e?
      e.returnValue = msg if e
      msg


module.exports = App
    