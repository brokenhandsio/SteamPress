import SteamPress

struct StubbedRandomNumberGenerator: SteamPressRandomNumberGenerator {
    let numberToReturn: Int

    func getNumber() -> Int {
        return numberToReturn
    }
}
