class Omnom.Feed
  @_postLoadedCallbacks: []

  @addPostLoadedCallback: (callback) ->
    @_postLoadedCallbacks.push callback

  constructor: (@el) ->
    @buttonFadeTime = 100
    @isReadButton = $('.update-is-read', @el)
    @refreshPostsButton = $('.refresh-posts', @el)
    @initIsReadButton()
    @initRefreshPostsButton()
    @onPostsLoad()

  initIsReadButton: ->
    @isReadButton.removeClass('hidden').hide()

    @toggleIsReadButton()

    @isReadButton.click (e) =>
      button = $(e.target)
      unreadPosts = @getUnreadPosts()
      postIds = $.map unreadPosts, (element) ->
        $(element).attr('data-post-id')
      $.ajax
        url: @isReadButton.attr('data-url')
        type: 'PUT'
        data:
          ids: postIds
          post:
            is_read: 1
        success: =>
          @refreshPostsButton.click()
        error: =>
          @fadeInRefreshPostsButton()

      $('html, body').animate({scrollTop: 0}, 'fast')
      @fadeOutRefreshPostsButton()
      button.blur()
      unreadPosts.addClass('post-is-read')
      @toggleIsReadButton()
      false

  initRefreshPostsButton: ->
    @refreshPostsButton.click =>
      @fadeOutRefreshPostsButton()
      $.ajax
        url: @refreshPostsButton.attr('data-url')
        success: (response) =>
          $('.posts', @el).html(response)
          @onPostsLoad()
        error: =>
          alert 'Sorry, there was an error updating the posts!'
        complete: (response) =>
          @fadeInRefreshPostsButton()
      false

  toggleIsReadButton: =>
    if @getUnreadPosts().length
      @isReadButton.fadeTo(@buttonFadeTime, 1)
    else
      @isReadButton.fadeTo(@buttonFadeTime, 0)

  fadeOutRefreshPostsButton: =>
    @refreshPostsButton.fadeTo(@buttonFadeTime, 0.3).find('i').addClass('icon-spin')
  
  fadeInRefreshPostsButton: =>
    @refreshPostsButton.fadeTo(@buttonFadeTime, 1).find('i').removeClass('icon-spin')
  
  getUnreadPosts: =>
    $('.posts > .post:not(.post-is-read)', @el)

  onPostsLoad: =>
    $('.posts abbr.timeago', @el).timeago()
    @toggleIsReadButton()
    for callback in Omnom.Feed._postLoadedCallbacks
      callback.apply()
