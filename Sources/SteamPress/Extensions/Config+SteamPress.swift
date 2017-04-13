import Settings

extension Settings.Config {
  var disabledPaths: [String] {
    return self["disabledPaths"]?.array?.flatMap { $0.string } ?? []
  }
}
