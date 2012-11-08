Spine       = require('spine/core')
$           = Spine.$
templates   = require('duality/templates')
session     = require('session')


class MainNav extends Spine.Controller
  className: 'main navbar'

  elements:
    'form.login':             'loginForm'
    'input[name=username]':   'formUsername'
    'input[name=password]':   'formPassword'
    'li a':                   'links'

  events:
    'submit form.login':      'login'
    'click .logout-button':   'logout'

  constructor: ->
    super
    @granted = false
    @render()
    @setup()

  render: =>
    @html templates.render('main-nav.html', {}, {})

  setup: =>
    @links.on 'click', (e) =>
      $link = $(e.currentTarget)
      @selectLink($link)

  selectFromClassName: (className) =>
    if className
      fragment = className.split(' ')[0]
      $link = @el.find("li.#{fragment} a")
      @selectLink($link)

  selectLink: ($link) =>
    if $link and not $link.hasClass('active')
      @links.removeClass('active')
      $link.addClass('active')

  showLogin: =>
    @resetLoginForm()
    @el.addClass('show-login')

  hideLogin: =>
    @el.removeClass('show-login')
    @resetLoginForm(false)

  login: (e) =>
    e.preventDefault()
    username = $.trim @formUsername.val()
    password = $.trim @formPassword.val()
    session.login username, password, (err, resp) =>
      if err
        alert "Oops! #{err}"
      else
        if 'manager' in resp.roles
          @granted = true
        else
          alert "User #{username} does not have permission"
      @resetLoginForm()

  logout: =>
    session.logout (err, resp) =>
      if err
        alert "Error signing out: #{err}"
      else
        @granted = false
      @resetLoginForm()

  resetLoginForm: (focus = true) =>
    @formUsername.val('')
    @formPassword.val('')
    @formUsername.focus() if focus


module.exports = MainNav