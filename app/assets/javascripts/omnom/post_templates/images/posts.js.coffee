Omnom.Feed.addPostLoadedCallback ->
  posts = $('.posts-template-images')
  return unless posts.length
  posts.imagesLoaded =>
    if posts.hasClass('masonry')
      posts.masonry('reload')
    else
      posts.masonry
        itemSelector: '.post'
        columnWidth: 280
