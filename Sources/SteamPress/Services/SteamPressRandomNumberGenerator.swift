import Vapor

public protocol SteamPressRandomNumberGenerator: Service {
    func getNumber() -> Int
}
