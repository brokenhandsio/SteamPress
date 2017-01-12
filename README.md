# SteamPress
SteamPress is a Swift blogging engine for use with the Vapor Framework to deploy blogs to sites that run on top of Vapor. It uses [Fluent](https://github.com/vapor/fluent) so will work with any database that has a Fluent Driver. It also incorporates [LeafMarkdown](https://github.com/brokenhandsio/LeafMarkdown) allowing you to write your posts in Markdown and then use Leaf to render the markdown.

The blog can either be used as the root of your website (i.e. appearing at https://www.acme.org) or in a subpath (i.e. https://www.acme.org/blog/).

There is an example of how it can work in a site (and what it requires in terms of Leaf templates and the parameteres is passes to them) at https://github.com/brokenhandsio/SteamPressExample.

## Features:

* Blog entries with Markdown
* Multiple user accounts
* Label tagging for blogging
* Snippet for posts
* Works with any Fluent driver
* Protected Admin route for creating blog posts

# How to Use

## Setup

It's just a single line! Well almost... First add it to your `Package.swift` dependencies:

```swift
dependencies: [
    ...,
    .Package(url: "https://github.com/brokenhandsio/SteamPress", majorVersion: 0, minor: 1)
]
```

Next import it in the file where you are setting up your `Droplet` with:

```swift
import SteamPress
```

Finally, initialise it!

```swift
let steamPress = SteamPress(drop: drop)
```

This will initialise it as the root path of your site. If you wish to have it in a subdirectory, initialise it with:

```swift
let steamPress = SteamPress(drop: drop, blogPath: "blog")
```

## Logging In

When you first visit the login page of the admin section of the blog it will create a user for you to use for login, with the username `admin`. The password will be printed out to the console and you will be required to reset your password when you first login. It is recommended you do this as soon as your site is up and running.

# Expected Leaf Templates

SteamPress expects there to be a number of Leaf template files in the correct location in `Resources/Views`. All these files should be in a `blog` directory, with the admin template files being in an `admin` directory. For an example of how it SteamPress works with the leaf templates, see the [Example SteamPress site](https://github.com/brokenhandsio/SteamPressExample).

The basic structure of your `Resources/View` directory should be:

* `blog`
 * `blog.leaf` - the main index page
 * `blogpost.leaf` - the page for a single blog post
 * `label.leaf` - the page for a label
 * `profile.leaf` - the page for a user profile
 * `admin`
  * `createPost.leaf` - the page for creating and editing a blog post
  * `createUser.leaf` - the page for creating and editing a user
  * `index.leaf` - the index page for the Admin site
  * `login.leaf` - the login page for the Admin site
  * `resetPassword.leaf` - the page for resetting your password

## Main Blog Site

### `blog.leaf`

This is the index page of the blog. The parameters it will receive are:

* `posts` - an array of blog posts if there are any. These will be long snippets (see below)
* `labels` - an array of labels if there are any
* `user` - the currently logged in user if a user is currently logged in
* `blogIndexPage` - a boolean saying we are on the index page of the blog - useful for navbars

### `blogpost.leaf`

This is the page for viewing a single entire blog post. The parameters set are:

* `post` - the full current post
* `author` - the author of the post
* `blogPostPage` - a boolean saying we are on the blog post page
* `user` - the currently logged in user if a user is currently logged in

### `label.leaf`

This is the page for a label. A blog post can be tagged with many labels and a label can be tagged on many blog posts. This page is generally used for viewing all posts under that label. The parameters are:

* `label` - the label
* `posts` - all the posts that have been tagged with this label
* `labelPage` - a boolean saying we are on the label page
* `user` - the currently logged in user if a user is currently logged in

### `profile.leaf`

This is the page for viewing a profile of a user. This is generally used for viewing all posts written by a user, as well as some information about them. This template is also used by the Admin section for viewing a 'My Profile' page when logged in. The parameters it can have set are:

* `user` - the user the page is for
* `myProfile` - a boolean set to true if we are viewing the my profile page
* `profilePage` - a boolean set to to true if we are viewing the profile page
* `posts` - all the posts the user has written if they have written any

## Admin Site

TODO

# Snippets

SteamPress supports two type of snippets for blog posts - short and long. Short snippets will provide the first paragraph or so of the blog post, whereas long snippets will show several paragraphs (such as for use on the main blog page, when listing all of the posts).

## Usage

TODO

# LeafMardown

LeafMarkdown allows you to render markdown as HTML in your Leaf files. To use, just simply use:

```
#markdown(myObject.markdownContent)
```

This will convert the `Node` object `myObject`'s `markdownContent` to HTML (you pass in `myObject` as a parameter to your Leaf view). It uses CommonMark under the hood, but for more details, see the [LeafMarkdown repo](https://github.com/brokenhandsio/LeafMarkdown).

# Known issues

* When the admin user is created when first accessing the login screen, sometimes two are created so you need to use the first password displayed. You can then delete the second Admin user in the Admin pane.
* Despite me being a big believer in TDD and it saving me on many occasions, I neglected to actually write any tests for this. So despite the fact that I have been tripped up due to no tests, I haven't written the unit tests yet, mainly because this started out as a Spike to see how easy it would be. They will definitely be coming soon!
* There is no 'remember me' logic when logging in yet, which means you will only be logged in for an hour until your session times out. Please remember this when writing long posts!
