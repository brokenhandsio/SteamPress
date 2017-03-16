import Console

struct PrintConsole: ConsoleProtocol {
    
    func output(_ string: String, style: ConsoleStyle, newLine: Bool) {
        Swift.print(string)
    }
    
    var size: (width: Int, height: Int) = (0, 0)
    
    func execute(program: String, arguments: [String], input: Int32?, output: Int32?, error: Int32?) throws {}
    
    func clear(_ clear: ConsoleClear) {}
    
    func input() -> String {
        return ""
    }
    
}
