Omnom
======
An everythingreader for programmers

Overview
--------

Omnom is a newsreader that lets you transform absolutely anything into a feed. Most newsreaders can only read web feeds (Atom, RSS, etc). Omnom reads **everything**.

Omnom lets you quickly see all of your daily reading (news, your Facebook feed, Google Analytics summaries, etc) in a single app. It lets you:

* Transform any online content into a feed
* Add expressive filters to sources and feeds using Ruby
* Mark posts as being "read" to avoid rereading them
* Create custom views for feeds

For example, you might set up four feeds like this:

* **Tech**: Hacker News, Slashdot, TechCrunch
* **Photos**: All of your friends' Facebook photos, Instagram photos, /r/Pics
* **Analytics**: Daily Google Analytics and Mixpanel summaries
* **MyStartup**: Tweets, Facebook posts, and Hacker News/TechCrunch/etc articles that mention "MyStartup"

Omnom is mobile-friendly and can be hosted on a single Heroku dyno for free. It looks like this:

[<img src="https://raw.github.com/tombenner/omnom/master/doc/iphone-tech.png" width="150" />](https://raw.github.com/tombenner/omnom/master/doc/iphone-tech.png)
[<img src="https://raw.github.com/tombenner/omnom/master/doc/desktop-tech.png" />](https://raw.github.com/tombenner/omnom/master/doc/desktop-tech.png)

It also includes a custom view for images:

[<img src="https://raw.github.com/tombenner/omnom/master/doc/iphone-photos.png" width="150" />](https://raw.github.com/tombenner/omnom/master/doc/iphone-photos.png)
[<img src="https://raw.github.com/tombenner/omnom/master/doc/desktop-photos.png" />](https://raw.github.com/tombenner/omnom/master/doc/desktop-photos.png)

Feeds are created in Ruby, which allows for expressive filtering:

```ruby
# app/feeds/tech_feed.rb

class TechFeed < Omnom::Feed
  sources do
    feed(url: 'http://daringfireball.net/index.xml')
    hacker_news(filter: Proc.new { |post| post.comments_count > 10 })
    slashdot
    techcrunch
  end
end
```

Many sources are already available (including `feed`, which reads Atom, RSS, etc), but you can also quickly create new ones. See [Sources](#sources) and [Creating Sources](#creating-sources) for details.

Installation
------------

Set up the example app:

```bash
git clone https://github.com/tombenner/omnom-app
cd omnom-app
cp config/database.example.yml config/database.yml # And edit
cp config/omnom.local.example.yml config/omnom.local.yml # And change the secret_token
rake db:setup
```

Then simply edit your feeds in app/feeds! (See [Feeds](#feeds) for details.)

#### Deploying to Heroku

If you've set settings in omnom.local.yml, the following command will print the `heroku config` command to set them on Heroku:

```shell
rake omnom:heroku:config
```

If you have a very large number of feeds and sources, you may want to increase the pool size from Heroku's default of 5 to 20:

```shell
heroku config -s | awk '/^DATABASE_URL=/{print $0 "?pool=20"}' | xargs heroku config:add
```

Usage
-----

The default email/password login is `admin@example.com`/`password`, but this can be changed:

```shell
User.first.update_attributes(email: 'me@example.com', password: 'mypassword', password_confirmation: 'mypassword')
```

Click the "check" button to mark all of the posts on the current page as being "read" and refresh the page with new, unread posts, if any exist.

Feeds
-----

To add a feed, define a class in app/feeds like the one below:

```ruby
# app/feeds/my_startup_feed.rb
class MyStartupFeed < Omnom::Feed
  sources do
    feed(url: 'http://daringfireball.net/index.xml')
    hacker_news(filter: Proc.new { |post| post.comments_count > 10 })
    slashdot
    techcrunch
    twitter__search(term: 'MyStartup')
  end

  # Optionally, add a filter:
  filter do |post|
    post.title.include?('MyStartup') || post.description.include?('MyStartup')
  end
end
```

See [Sources](#sources) for a list of available sources. Some sources (mostly just the authenticated ones, like Facebook) require configuration in omnom.local.yml. 

You can add filters for a specific source and filters for the entire feed.

Sources
-------

The following sources are available (see [Source Descriptions](#source-descriptions)):

* **facebook** - Homepage feed of the authenticated user
* **feed** - Supports all Atom and RSS feeds
* **github** - Homepage feed of the authenticated user
* **github__blog** - Blog posts
* **github__blog\_section** - Blog posts for a section (e.g. Meetups)
* **google\_analytics** - Customizable metrics for the specified profile
* **google\_analytics__pageviews** - Daily pageviews for the specified profile
* **google\_analytics__visitors** - Daily visitors for the specified profile
* **hacker\_news** - Homepage posts
* **instagram** - Homepage feed of the authenticated user
* **reddit** - Homepage or subreddit posts
* **reddit__images** - Same as reddit, but includes full-size images
* **slashdot** - Homepage blog posts
* **stackoverflow** - Questions, as listed on any Stackoverflow page
* **techcrunch** - Homepage blog posts
* **techcrunch__section** - Blog posts for a section (e.g. Startups)
* **the\_next\_web** - Homepage blog posts
* **twitter__search** - Tweet results from a search
* **xkcd** - Comics

You can also create new sources *very* easily (see [Creating Sources](#creating-sources)). Please contribute them!

## Source Descriptions

Each source may have:

* **Config**: Configuration values that should be set in omnom.local.yml
* **Options**: Options that should be set in the source method's argument<br />
(e.g. `reddit(subreddit: 'r/programming')`)
* **Additional Data**: Additional data about the post stored in `post.other` (see [Posts](#posts))

### facebook

An authenticated user's Facebook feed

##### Config

* `web_auth_email`: The email used for Facebook authentication
* `web_auth_password`: The password used for Facebook authentication

##### Additional Data

* `images`: Photos contained in the post

### feed

An Atom or RSS feed

##### Options

* `url`: The feed's URL

### github

A user's Github feed

##### Config

* `atom`: The URL of the user's private Atom feed<br />
(e.g. `https://github.com/tombenner.private.atom?token=123456789012345678901234567890`)

### github__blog

[The Github Blog](https://github.com/blog)

### github__blog\_section

A section of [the Github Blog](https://github.com/blog) (e.g. "Meetups")

##### Options

* `section`: A symbol representing the section (e.g. `:broadcasts`, `:meetups`, `:enterprise`)

### google\_analytics__* Overview 

Google Analytics sources all require the following:

##### Config

* `client_id`, `client_secret`, `oauth_token`, `oauth_refresh_token`: Obtain these using [this gist](https://gist.github.com/jotto/2932998), using:<br />
`scope = "https://www.googleapis.com/auth/analytics.readonly"` 

##### Options

* `profile_id`: The ID of the profile you want to track. To find this, navigate to the profile in the web interface. The ID is the number between the `w` and `p` in the URL; it's `22222222` in the URL below:<br />
`https://www.google.com/analytics/web/?hl=en&pli=1#report/visitors-overview/a11111111w22222222p33333333/`

### google\_analytics

Daily Google Analytics summaries

See "google\_analytics__* Overview"

##### Options

* `metrics`: An array of symbols representing [metrics](https://developers.google.com/analytics/devguides/reporting/core/dimsmets) to be tracked<br />
(e.g. `[:pageviews, :visitors]`)

### google\_analytics__pageviews

Daily pageviews count

See "google\_analytics__* Overview"

### google\_analytics__visitors

Daily visitors count

See "google\_analytics__* Overview"

### hacker\_news

The front page of Hacker News

##### Additional Data

* `points_count`

### instagram

An authenticated user's Instagram feed

##### Config

* `web_auth_username`: The username used for Instagram authentication
* `web_auth_password`: The password used for Instagram authentication

##### Additional Data

* `images`: An array containing the photo
* `likes_count`
* `location`: A hash of data about the location, if present

### reddit

The front page of Reddit or a subreddit

##### Options

* `subreddit`: A subreddit (e.g. [`'r/programming'`](http://www.reddit.com/r/programming))

##### Additional Data

* `likes_count`

### reddit__images

Same as `reddit`, except that the URLs of the full-sized images are also gathered 

##### Options

* `subreddit`: A subreddit (e.g. [`'r/programming'`](http://www.reddit.com/r/programming))

##### Additional Data

* `images`: An array containing the post's full-sized image(s)
* `likes_count`

### slashdot

The front page of Slashdot

### stackoverflow

Any page on Stackoverflow that has a list of questions

##### Options

* `path`: The path to the page (e.g. [`'questions/tagged/ruby'`](http://stackoverflow.com/questions/tagged/ruby))

##### Additional Data

* `answers_count`
* `views_count`
* `votes_count`

### techcrunch

The front page of TechCrunch

### techcrunch__section

A section of TechCrunch

##### Options

* `section`: A symbol representing the section (e.g. `:startups`, `:gadgets`, `:social`)

### the\_next\_web

The front page of The Next Web

### twitter__search

A Twitter search

##### Config

* `consumer_key`, `consumer_secret`, `oauth_token`, `oauth_token_secret`: Obtain these [here](https://dev.twitter.com/docs/auth/tokens-devtwittercom)

##### Options

* `term`: The search term
* `search_options`: Search options; the second argument in a [Twitter.search()](https://github.com/sferik/twitter) call (optional)

##### Additional Data

* `geo`: Geographic data about the tweet
* `media`: Media (images) attached to the tweet
* `source`: The app the tweet was created on
* `to_user`: The user the tweet was sent to

### xkcd

XKCD

##### Additional Data

* `images`: An array containing the image

Posts
-----

Posts will be created automatically for each source by background workers. A post has the following attributes:

* `title`
* `description`
* `guid`
* `url`
* `published_at`
* `thumbnail_url`
* `author_name`
* `author_url`
* `comments_count`
* `comments_url`
* `tags`
* `other`: A hash of additional data about the post (e.g. images, likes_count)

Creating Sources
----------------

Omnom's power lies in its ability to easily turn anything into a source. If there's a source you'd like to add, feel free to do so!

Here's an example:

```ruby
# lib/omnom/source/my_source/default.rb
module Omnom
  module Source
    module MySource
      class Default < Source::Base
        url 'http://someblog.com/'
        every '5m'

        def get_raw_posts
          @page.search('.main-content > div.post')
        end

        def post_attributes(node)
          {
            title: node.search('h2').text,
            description: node.search('.post-description').inner_html,
            guid: node.attr('data-post-id'),
            url: node.find('a.title').url,
            published_at: node.find('.post-created-at').time(time_zone: 'America/New_York'),
            thumbnail_url: node.find('.post-image > img').attr('src'),
            author_name: node.find('.post-author').text,
            author_url: node.find('.post-author').url,
            comments_count: node.find('.post-comments').text,
            comments_url: node.find('.post-comments').url,
            tags: node.search('.post-tags .post-tag').collect { |tag| tag.text },
            other: {
              likes_count: node.find('.post-likes').text.to_i
            }
          }
        end
      end
    end
  end
end
```

Every source must define:

* `every` or `cron` - When the posts will be created/updated
* `get_raw_posts` - Should return an Enumerable of the page's posts, which will be passed to `post_attributes`
* `post_attributes` - Given a raw post, should return a hash of the post's attributes that'll be saved

`url` is also often used to set the URL for the `@page`. It's not required, though, as some sources (e.g. GoogleAnalytics) gather data using methods other than web scraping.

This source is now ready to be used in a feed:

```ruby
class MyFeed < Omnom::Feed
  sources do
    my_source
  end
end
```

If you create another source within the MySource namespace and name its class News instead of Default, you would refer to it using `my_source__news` instead of `my_source`.

You can create sources within the `lib` of [omnom-app](https://github.com/tombenner/omnom-app), but when you want to contribute them, please move them to the `lib` of the [omnom](https://github.com/tombenner/omnom) gem.

Contributing
------------

Please contribute! Omnom could potentially become an interesting and powerful way to read the internet, and new sources are especially very appreciated.

The [omnom](https://github.com/tombenner/omnom) gem is an engine that lives inside of [omnom-app](https://github.com/tombenner/omnom-app). This allows you to create and modify feeds and sources at your whim and commit them and deploy them to your server without touching the core codebase of omnom.

If you'd like to modify the omnom gem, though, you'll want to clone it and then point omnom-app's Gemfile to your local copy:

```ruby
gem 'omnom', path: '../path/to/omnom'
```

Please add specs to `test/dummy`, and definitely be sure to include a spec for any new sources.

Omnom uses [nikkou](https://github.com/tombenner/nikkou), which makes the extraction of useful data from HTML and XML easier. If you see any methods that could be added to nikkou, absolutely feel free to add them, too.

FAQ
---

### "Omnom"?

Omnom loves to eat, and it can injest and digest anything. It's **omn**iscient, **omn**ivorous, and **omn**ificent.

License
-------

Omnom is released under the MIT License. Please see the MIT-LICENSE file for details.
