# SteamPress
SteamPress is a Swift blogging engine for use with the Vapor Framework to deploy blogs to sites that run on top of Vapor. It uses [Fluent](https://github.com/vapor/fluent) so will work with any database that has a Fluent Driver. It also incorporates [LeafMarkdown](https://github.com/brokenhandsio/LeafMarkdown) allowing you to write your posts in Markdown and then use Leaf to render the markdown.

The blog can either be used as the root of your website (i.e. appearing at https://www.acme.org) or in a subpath (i.e. https://www.acme.org/blog/).

There is an example of how it can work in a site (and what it requires in terms of Leaf templates and the parameteres is passes to them) at https://github.com/brokenhandsio/SteamPressExample.

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

## Expected Leaf Templates

TODO

### Main Blog Site

TODO

### Admin Site

TODO

## Snippets

SteamPress supports two type of snippets for blog posts - short and long. Short snippets will provide the first paragraph or so of the blog post, whereas long snippets will show several paragraphs (such as for use on the main blog page, when listing all of the posts).

### Usage

TODO

## LeafMardown

LeafMarkdown allows you to render markdown as HTML in your Leaf files. To use, just simply use:

```
#markdown(myObject.markdownContent)
```

This will convert the `Node` object `myObject`'s `markdownContent` to HTML (you pass in `myObject` as a parameter to your Leaf view). It uses CommonMark under the hood, but for more details, see the [LeafMarkdown repo](https://github.com/brokenhandsio/LeafMarkdown).

# Known issues

When the admin user is created when first accessing the login screen, sometimes two are created so you need to use the first password displayed. You can then delete the second Admin user in the Admin pane.

Despite me being a big believer in TDD and it saving me on many occasions, I neglected to actually write any tests for this. So despite the fact that I have been tripped up due to no tests, I haven't written the unit tests yet, mainly because this started out as a Spike to see how easy it would be. They will definitely be coming soon!
