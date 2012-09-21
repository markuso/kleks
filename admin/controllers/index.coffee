Spine       = require('spine/core')
require('spine/route')
require('spine/manager')

templates   = require('duality/templates')
session     = require('session')

MainNav   = require('controllers/main-nav')
MainStack   = require('controllers/main-stack')


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
    @mainNav   = new MainNav
    @mainStack = new MainStack

    @append @mainNav, @mainStack

    Spine.Route.setup()


module.exports = App
    