extension Array where Element: BlogUser {
    func getAuthorName(id: Int) -> String {
        return self.filter { $0.userID == id }.first?.name ?? ""
    }
    
    func getAuthorUsername(id: Int) -> String {
        return self.filter { $0.userID == id }.first?.username ?? ""
    }
}
