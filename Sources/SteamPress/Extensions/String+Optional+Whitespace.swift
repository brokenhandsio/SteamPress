extension Optional where Wrapped == String {
    func isEmptyOrWhitespace() -> Bool {
        guard let string = self else {
            return true
        }
        
        return string.trimmingCharacters(in: .whitespaces).isEmpty
    }
}
