public struct RealRandomNumberGenerator: SteamPressRandomNumberGenerator {
    public init() {}

    public func getNumber() -> Int {
        return Int.random(in: 1...999)
    }
}
