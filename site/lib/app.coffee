# App's main client script

$ = require('jquery')

exports.initialize = (config) ->
  touch = Modernizr.touch

  $mainNav = $('.main-nav')
  $mainNavIcon = $mainNav.find('> .icon')
  $mainNavList = $mainNav.find('> ul')
  
  $tocNav = $('.toc-nav')
  $tocNavIcon = $tocNav.find('> .icon')
  $tocNavList = $tocNav.find('> ul')
  
  $collectionNav = $('.collection-nav')
  $collectionNavIcon = $collectionNav.find('> .icon')
  $collectionNavList = $collectionNav.find('> ul')
  
  $article = $('.container > article')

  hidePopups = (exceptMe) ->
    $mainNavList.hide() unless $mainNavList is exceptMe
    $tocNavList.hide() unless $tocNavList is exceptMe
    $collectionNavList.hide() unless $collectionNavList is exceptMe

  $('html').on 'click', (e) ->
    hidePopups()
  
  # Setup the Main menu
  $mainNavIcon.on 'click', (e) ->
    e.stopPropagation()
    hidePopups($mainNavList)
    $mainNavList.toggle()

  # Setup the TOC menu
  if $tocNav and $article
    $article.find('h3').each ->
      heading = $(@)
      text = heading.text()
      headingId = 'TOC-' + text.replace(/[\ \.\?\#\'\"]/g, '-')
      heading.attr('id', headingId)
      $tocNavList.append "<li><a href=\"##{headingId}\">#{text}</a></li>"

    $tocNavIcon.on 'click', (e) ->
      e.stopPropagation()
      hidePopups($tocNavList)
      $tocNavList.toggle()

  # Setup the Collection menu
  if $collectionNav
    $collectionNavId = $collectionNav.attr('data-id')
    if $collectionNavId
      for c in [1...5]
        $collectionNavList.append "<li><a href=\"#\">Essay Number #{c}</a></li>"

    $collectionNavIcon.on 'click', (e) ->
      e.stopPropagation()
      hidePopups($collectionNavList)
      $collectionNavList.toggle()
