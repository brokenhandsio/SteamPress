import Settings

extension Settings.Config {
  var enableAuthorsPages: Bool {
    return self["enableAuthorsPages"]?.bool ?? true
  }

  var enableTagsPages: Bool {
    return self["enableTagsPages"]?.bool ?? true
  }
}
