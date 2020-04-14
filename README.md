<p align="center">
    <img src="https://user-images.githubusercontent.com/9938337/29742058-ed41dcc0-8a6f-11e7-9cfc-680501cdfb97.png" alt="SteamPress">
    <br>
    <br>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/Swift-5.2-brightgreen.svg" alt="Language">
    </a>
    <a href="https://github.com/brokenhandsio/SteamPress/actions">
        <img src="https://github.com/brokenhandsio/SteamPress/workflows/CI/badge.svg?branch=master" alt="Build Status">
    </a>
    <a href="https://codecov.io/gh/brokenhandsio/SteamPress">
        <img src="https://codecov.io/gh/brokenhandsio/SteamPress/branch/master/graph/badge.svg" alt="Code Coverage">
    </a>
    <a href="https://raw.githubusercontent.com/brokenhandsio/SteamPress/master/LICENSE">
        <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT License">
    </a>
</p>

SteamPress is a Swift blogging engine for use with the Vapor Framework to deploy blogs to sites that run on top of Vapor. It uses protocols to define database storage, so will work with any database that has a `SteamPressRepository` implementation, or you can write your own! It also incorporates a [Markdown Provider](https://github.com/vapor-community/markdown-provider) allowing you to write your posts in Markdown and then use Leaf to render the markdown.

The blog can either be used as the root of your website (i.e. appearing at https://www.acme.org) or in a subpath (i.e. https://www.acme.org/blog/).

There is an example of how it can work in a site (and what it requires in terms of Leaf templates and the parameters is passes to them) at https://github.com/brokenhandsio/SteamPressExample.

## Features:

* Blog entries with Markdown
* Multiple user accounts
* Tags on blog posts
* Snippet for posts
* Draft Posts
* Works with any Fluent driver
* Protected Admin route for creating blog posts
* Pagination on the main blog page
* Slug URLs for SEO optimisation and easy linking to posts
* Support for comments via Disqus
* Open Graph and Twitter Card support
* RSS/Atom Feed support
* Blog Search

# How to Use

## Add as a dependency

**TODO** Update

SteamPress is easy to integrate with your application. There are two providers that provide implementations for [PostgreSQL](https://github.com/brokenhandsio/steampress-fluent-postgres) or [MySQL](https://github.com/brokenhandsio/steampress-fluent-mysql). You are also free to write your own integrations. Normally you'd choose one of the implementations as that provides repository integrations for the database. In this example, we're using Postgres.

First, add the provider to your `Package.swift` dependencies:

```swift
dependencies: [
    // ...
    .package(name: "SteampressFluentPostgres", url: "https://github.com/brokenhandsio/steampress-fluent-postgres.git", from: "2.0.0"),
],
```

Then add it as a dependecy to your application target:


```swift
.target(name: "App",
    dependencies: [
        // ...
        "SteampressFluentPostgres"
    ])
```

In `configure.swift`, import the provider:

```swift
import SteampressFluentPostgres
```

Next, register the provider with your services:

```swift
try services.register(SteamPressFluentPostgresProvider())
```

The Provider's require you to add SteamPress' models to your migrations:

```swift
/// Configure migrations
var migrations = MigrationConfig()
// ...
migrations.add(model: BlogTag.self, database: .psql)
migrations.add(model: BlogUser.self, database: .psql)
migrations.add(model: BlogPost.self, database: .psql)
migrations.add(model: BlogPostTagPivot.self, database: .psql)
// Optional but recommended - this will create an admin user for you to login with
migrations.add(migration: BlogAdminUser.self, database: .psql)
services.register(migrations)
```

## Manual Setup

First add SteamPress to your `Package.swift` dependencies:

```swift
dependencies: [
    // ...,
    .package(name: "SteamPress", url: "https://github.com/brokenhandsio/SteamPress", from: "2.0.0")
]
```

And then as a dependency to your target:

```swift
.target(name: "App",
    dependencies: [
        // ...
        "SteamPress"
    ])
```

This will register the routes for you. You must provide implementations for the different repository types to your services:

```swift
app.steampress.blogRepositories.use { application in
    MyRepository(application: application)
}
```

SteamPress will be automatically registered, depending on the configuration provided (see below).

## Integration

SteamPress offers a 'Remember Me' functionality when logging in to extend the duration of the session. In order for this to work, you must register the middleware:

```swift
application.middlewares.use(BlogRememberMeMiddleware())
```

**Note:** This must be registered before you register the `SessionsMiddleware`.

**TODO: Update**

Finally, if you wish to use the `#markdown()` tag with your blog Leaf templates, you must register this. There's also a paginator tag, to make pagination easy:

```swift
var tags = LeafTagConfig.default()
tags.use(Markdown(), as: "markdown")
let paginatorTag = PaginatorTag(paginationLabel: "Blog Posts")
tags.use(paginatorTag, as: PaginatorTag.name)
services.register(tags)
```

## Configuration

There are a number of configuration options you can pass to the provider to configure SteamPress:

* `blogPath`: the path to add the blog to. By default the blog routes will be registered to the root of your site, but you may want to register the blog at `/blog`. So if you pass in `"blog"` the blog will be available at `https://www.mysite.com/blog`.
* `feedInformation`: Information to vend to the RSS and Atom feeds.
* `postsPerPage`: The number of posts to show per page on the main index page of the blog. Defaults to 10.
* `enableAuthorsPages`: Flag used to determine whether to publicly expose the authors endpoints or not. Defaults to true.
* `enableTagsPages`: Flag used to determine whether to publicy expose the tags endpoints or not. Defaults to true.

To configure these, you can pass them to the provider. E.g.:

```swift
let feedInformation = FeedInformation(
    title: "The SteamPress Blog", 
    description: "SteamPress is an open-source blogging engine written for Vapor in Swift", 
    copyright: "Released under the MIT licence", 
    imageURL: "https://user-images.githubusercontent.com/9938337/29742058-ed41dcc0-8a6f-11e7-9cfc-680501cdfb97.png")
application.steampress.configuration = SteamPressConfiguration(blogPath: "blog", feedInformation: feedInformation, postsPerPage: 5)
```

Additionally, you should set the `WEBSITE_URL` environment variable to the root address of your website, e.g. `https://www.steampress.io`. This is used to set various parameters throughout SteamPress.

## Logging In

When you first launch SteamPress, if you've enabled the `BlogAdminUser` migration, an admin user is created in the database. The username is `admin` and the password will be printined out to your app's logs. It is recommended that you reset your password when you first login as soon as your site is up and running.

## Comments

SteamPress currently supports using [Disqus](https://disqus.com) for the comments engine. To use Disqus, start the app with the environment variable `BLOG_DISQUS_NAME` set to the name of your disqus sute. (You can get the name of your Disqus site from your Disqus admin panel)

This will pass it through to the Leaf templates for the Blog index (`blog.leaf`), blog posts (`blogpost.leaf`), author page (`profile.leaf`) and tag page (`tag.leaf`) so you can include it if needs be. If you want to manually set up comments you can do this yourself and just include the necessary files for your provider. This is mainly to provide easy configuration for the [example site](https://github.com/brokenhandsio/SteamPressExample).

## Open Graph Twitter Card Support

SteamPress supports both Open Graph and Twitter Cards. The blog post page context will pass in the created date and last edited date (if applicable) in ISO 8601 format for Open Graph article support, under the parameters `createdDateNumeric` and `lastEditedDateNumeric`.

The Blog Post page will also be passed a number of other useful parameters for Open Graph and Twitter Cards. See the `blogpost.leaf` section below.

The Twitter handle of the site can be configured with a `BLOG_SITE_TWITTER_HANDLE` environment variable (the site's twitter handle without the `@`). If set, this will be injected into the public pages as described below. This is for the `twitter:site` tag for Twitter Cards

## Google Analytics Support

SteamPress makes it easy to integrate Google Analytics into your blog. Just start the application with the `BLOG_GOOGLE_ANALYTICS_IDENTIFIER` environment variable set to you Google Analytics identifier. (You can get your identifier from the Google Analytics console, it will look something like UA-12345678-1)

This will pass a `googleAnalyticsIdentifier` parameter through to all of the public pages in the `pageInformation` variable, which you can include and then use the [Example Site's javascript](https://github.com/brokenhandsio/SteamPressExample/blob/master/Public/static/js/analytics.js) to integrate with.

## Atom/RSS Support

SteamPress automatically provides endpoints for registering RSS readers, either using RSS 2.0 or Atom 1.0. These endpoints can be found at the blog's `atom.xml` and `rss.xml` paths; e.g. if you blog is at `https://www.example.com/blog` then the atom feed will appear at `https://wwww.example.com/blog/atom.xml`. These will work by default, but you will probably want to configure some of fields. These are configured with the `FeedInformation` parameter passed to the provider. The configuration options are:

* `title` - the title of the blog - a default "SteamPress Blog" will be provided otherwise
* `description` - the description of the blog (or subtitle in atom) - a default "SteamPress is an open-source blogging engine written for Vapor in Swift" will be provided otherwise
* `copyright` - an optional copyright message to add to the feeds
* `imageURL` - an optional image/logo to add to the feeds. Note that for Atom this should a 2:1 landscape scaled image

## Search Support

SteamPress has a built in blog search. It will register a route, `/search`, under your blog path which you can send a query through to, with a key of `term` to search the blog.

# Expected Leaf Templates

SteamPress expects there to be a number of Leaf template files in the correct location in `Resources/Views`. All these files should be in a `blog` directory, with the admin template files being in an `admin` directory. For an example of how it SteamPress works with the leaf templates, see the [Example SteamPress site](https://github.com/brokenhandsio/SteamPressExample).

For every public Leaf template, a `pageInformation` parameter will be passed in with the following information:

* `disqusName`: The site Disqus name, as discussed above
* `siteTwitterHandle`: The site twitter handle, as discussed above
* `googleAnalyticsIdentifier`: The Google Analytics identifer as discussed above
* `loggedInUser`: The currently logged in user, if a user is logged in. This is useful for displaying a 'Create Post' link throughout the site when logged in etc.
* `websiteURL`: The URL for the website
* `currentPageURL`: The URL of the current page
* `currentPageEncodedURL`: An URL encoded representation of the current page

For admin pages, the `pageInformation` parameter has the following information:

* `loggedInUser`: The currently logged in user, if a user is logged in. This is useful for displaying a 'Create Post' link throughout the site when logged in etc.
* `websiteURL`: The URL for the website
* `currentPageURL`: The URL of the current page

The basic structure of your `Resources/View` directory should be:

* `blog`
  * `blog.leaf` - the main index page
  * `blogpost.leaf` - the page for a single blog post
  * `tag.leaf` - the page for a tag
  * `profile.leaf` - the page for a user profile
  * `tags.leaf` - the page for displaying all of the tags
  * `authors.leaf` - the page for displaying all of the authors
  * `search.leaf` - the page to display search results
  * `admin`
    * `createPost.leaf` - the page for creating and editing a blog post
    * `createUser.leaf` - the page for creating and editing a user
    * `index.leaf` - the index page for the Admin site
    * `login.leaf` - the login page for the Admin site
    * `resetPassword.leaf` - the page for resetting your password

## Main Blog Site

### `blog.leaf`

This is the index page of the blog. The parameters it will receive are:

* `posts` - an array containing `ViewBlogPost`s. This contains all the post information and extra stuff that's useful, such as other date formats and snippets.
* `tags` - an array of `ViewBlogTag`s if there are any
* `authors` - an array of the authors if there are any
* `pageInformation` - general page information (see above)
* `title` - the title for the page
* `blogIndexPage` - a boolean saying we are on the index page of the blog - useful for navbars
* `paginationTagInformation` - information for enabling pagination on the page. See `PaginationTagInformation` for more details.

### `blogpost.leaf`

This is the page for viewing a single entire blog post. The parameters set are:

* `title` - the title of the blog post
* `post` - the blog post as a `ViewBlogPost`
* `author` - the author of the post
* `blogPostPage` - a boolean saying we are on the blog post page
* `pageInformation` - general page information (see above)
* `postImage` - The first image in the blog post if one is there. Useful for OpenGraph and Twitter Cards
* `postImageAlt` - The alt text of the first image if it exists. Useful for Twitter Cards
* `shortSnippet`: The HTML of the short snippet of the post on a single line with all HTML tags stripped out for the `description` tags

### `tag.leaf`

This is the page for a tag. A blog post can be tagged with many tags and a tag can be tagged on many blog posts. This page is generally used for viewing all posts under that tag. The parameters are:

* `tag` - the tag
* `posts` - an array of `ViewBlogPost`s that have been tagged with this tag. Note that this may not be all the posts due to pagination
* `tagPage` - a boolean saying we are on the tag page
* `postCount` - the number of posts in total that have this tag
* `pageInformation` - general page information (see above)
* `paginationTagInformation` - information for enabling pagination on the page. See `PaginationTagInformation` for more details.

### `profile.leaf`

This is the page for viewing a profile of a user. This is generally used for viewing all posts written by a user, as well as some information about them. The parameters it can have set are:

* `author` - the user the page is for
* `posts` - an array of `ViewBlogPost`s that have been written by this user. Note that this may not be .all the posts due to pagination
* `profilePage` - a boolean set to to true if we are viewing the profile page
* `myProfile` - a boolean set if the currently logged in user is viewing their own profile page
* `postCount` - the number of posts in total that have this tag
* `pageInformation` - general page information (see above)
* `paginationTagInformation` - information for enabling pagination on the page. See `PaginationTagInformation` for more details.

### `tags.leaf`

This is the page for viewing all of the tags on the blog. This provides some more navigation points for the blog as well as providing a page in case the user strips off the tag from the Tag's URL. The parameters that can be passed to it are:

* `title` - a title for the page
* `tags` - an array of `BlogTagWithPostCount`s. This is the tags with the number of posts tagged with that tag
* `pageInformation` - general page information (see above)

### `authors.leaf`

This is the page for viewing all of the authors on the blog. It provides a useful page for user's to see everyone who has contributed to the site.

* `authors` - an array of all the `ViewBlogAuthor`s on the blog
* `pageInformation` - general page information (see above)

### `search.leaf`

This is the page that will display search results. It has a number of parameters on it on top of the standard parameters:

* `title` - a title for the page
* `searchTerm` - the search term if provided
* `totalResults` - the number of results returned from the search
* `posts` - an array of `ViewBlogPost`s returned in the search. Note that this may not be all the posts due to pagination.
* `pageInformation` - general page information (see above)
* `paginationTagInformation` - information for enabling pagination on the page. See `PaginationTagInformation` for more details.

### `login.leaf`

This is the page for logging in to the admin section of the blog. The parameters are:
* `title` - a title for the page
* `errors` - an array of error messages if there were any errors logging in
* `loginWarning` - a flag set if the user tried to access a protected page and was redirected to the login page
* `username` - the username supplied (if any) when originally submitting the login for and there (useful for pre-populating the form)
* `usernameError` - a boolean set if there was an issue with the username
* `passwordError` - a boolean set if there was an error with the password (note that we do not pass any password submitted back to any pages if there was an error for security reasons)
* `rememberMe` - set if the remember me checkbox was checked and there was an error, useful for pre-populating
* `pageInformation` - general page information (see above)

## Admin Site

### `index.leaf`

This is the main Admin page for the blog where you can create and edit users and posts. The parameters for this page are:

* `users` - all the users for the site
* `publishedPosts` - all the posts that have been published if there are any, , as `ViewBlogPostWithoutTags`
* `draftPosts` - all the draft posts that have been saved but not published, if there are any, as `ViewBlogPostWithoutTags`
* `errors` - any error messages for errors that have occurred when trying to delete posts or users (for instance trying to delete yourself or the last user)
* `blogAdminPage` - a boolean set to true, useful for navigation
* `title` - the title for the page
* `pageInformation` - general page information as `BlogAdminPageInformation` - see above

### `resetPassword.leaf`

This is the page you will be redirected to if you need to reset your password. The parameters are:

* `errors` - an array of errors if there were any errors resetting your password
* `passwordError` - a boolean set if there was an error with the password (for instance it was blank)
* `confirmPasswordError` - a boolean set if there was an error with the password confirm (for instance it was blank)
* `pageInformation` - general page information as `BlogAdminPageInformation` - see above

### `createPost.leaf`

This is the page for creating a new blog post, or editing an existing one. The parameters for this page are:

* `title` - the title for the page
* `editing` - a boolean set to true if we are currently editing the a blog post rather than creating a new one
* `post` - the post object we are currently editing
* `draft` - a flag that's set when the post has been saved as a draft
* `errors` - an array of error messages if there were any errors creating or editing the blog post
* `titleSupplied` - the title of the blog post to edit, or the post that failed to be created
* `contentsSupplied` - the contents of the blog post to edit, or the post that failed to be created
* `tagsSupplied` - an array of all of the tags that have been specified for the blog post
* `slugURLSupplied` - the slug URL of the blog post to edit, or the post that failed to be created
* `titleError` - a boolean set to true if there was an error with the title
* `contentsError` - a boolean set to true if there was an error with the blog contents
let postPathPrefix: String
* `postPathPrefix` - the path to the post page that would be created or we are editing
* `pageInformation` - general page information as `BlogAdminPageInformation` - see above

### `createUser.leaf`

This is the page for creating a new user, or editing an existing one. The parameters are:

* `title` - the title for the page
* `editing` - a boolean set to true if we are editing a user
* `errors` - an array of error messages if there were any errors editing or creating the user
* `nameSupplied` - the name of the user we are editing or that we failed to create
* `nameError` - a boolean set if there was an error with the name
* `usernameSupplied` - the username of the user we are editing or that we failed to create
* `usernameError` - a boolean set if there was an error with the username
* `passwordError` - a boolean set to true if there was an error with the password
* `confirmPasswordError` - a boolean set to true if there was an error with the password confirm
* `resetPasswordOnLoginSupplied` - a boolean set to true if the edit/create submission was asked to reset the users password on next login (this is only supplied in an error so you can pre-populate the form for a user to correct without losing any information)
* `userID` - this is the ID of the user if we are editing one. This allows you to send the edit user `POST` back to the correct route
* `twitterHandleSupplied` - the twitter handle of the user we are editing or that we failed to create
* `profilePictureSupplied` - the URL of the profile picture of the user we are editing or that we failed to create
* `biographySupplied` - the biography of the user we are editing or that we failed to create
* `taglineSupplied` - the tagline of the user we are editing or that we failed to create
* `pageInformation` - general page information as `BlogAdminPageInformation` - see above

## `POST` Routes

There are a number of `POST` routes to the Admin site for creating and editing user etc that are required otherwise you will receive errors.

This section needs to be filled out, but you can view the Controllers in the code to work out what they should be, or see the [Example Site](https://github.com/brokenhandsio/SteamPressExample).

## Markdown Tag

The Markdown Tag allows you to render markdown as HTML in your Leaf files. To use, just simply use:

```
#markdown(myObject.markdownContent)
```

This will convert the object `myObject`'s `markdownContent` to HTML (you pass in `myObject` as a parameter to your Leaf view). It uses Github Flavoured Markdown under the hood, but for more details, see the [Leaf Markdown repo](https://github.com/vapor-community/leaf-markdown).

# API

SteamPress also contains an API for accessing certain things that may be useful. The current endpoints are:

* `/<blog-path>/api/tags/` - returns all the tags that have been saved in JSON
