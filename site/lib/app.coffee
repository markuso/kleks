# App's main client script

$ = require('jquery')

exports.initialize = (config) ->
  touch = Modernizr.touch

  $mainNav = $('.main-nav')
  $mainNavIcon = $mainNav.find('> .icon')
  $mainNavList = $mainNav.find('> ul')
  
  $mainNavIcon.on 'click', (e) ->
    $mainNavList.toggle()
