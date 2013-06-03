$ ->
  $('.feed').each (index, element) =>
    new Omnom.Feed($(element))
  $('abbr.timeago').timeago()
