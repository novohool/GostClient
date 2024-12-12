import Foundation

struct LogEntry: Identifiable {
    let id = UUID()
    let timestamp: Date
    let level: LogLevel
    let message: String
    
    enum LogLevel: String {
        case info = "INFO"
        case error = "ERROR"
        case debug = "DEBUG"
        case warning = "WARNING"
        
        var color: String {
            switch self {
            case .info: return "blue"
            case .error: return "red"
            case .debug: return "gray"
            case .warning: return "orange"
            }
        }
    }
}

class LogManager: ObservableObject {
    static let shared = LogManager()
    
    @Published var logs: [LogEntry] = []
    private let maxLogEntries = 1000
    private let logFileURL: URL
    
    init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        logFileURL = documentsPath.appendingPathComponent("gost.log")
        
        // 从文件加载日志
        loadLogsFromFile()
    }
    
    func addLog(_ message: String, level: LogEntry.LogLevel) {
        let entry = LogEntry(timestamp: Date(), level: level, message: message)
        DispatchQueue.main.async {
            self.logs.insert(entry, at: 0)
            if self.logs.count > self.maxLogEntries {
                self.logs.removeLast()
            }
        }
        
        // 写入文件
        writeLogToFile(entry)
    }
    
    func clearLogs() {
        DispatchQueue.main.async {
            self.logs.removeAll()
        }
        
        // 清除日志文件
        try? "".write(to: logFileURL, atomically: true, encoding: .utf8)
    }
    
    private func writeLogToFile(_ entry: LogEntry) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestamp = formatter.string(from: entry.timestamp)
        let logLine = "[\(timestamp)] [\(entry.level.rawValue)] \(entry.message)\n"
        
        if let data = logLine.data(using: .utf8) {
            if let fileHandle = try? FileHandle(forWritingTo: logFileURL) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                try? fileHandle.close()
            } else {
                try? logLine.write(to: logFileURL, atomically: true, encoding: .utf8)
            }
        }
    }
    
    private func loadLogsFromFile() {
        guard let logData = try? String(contentsOf: logFileURL, encoding: .utf8) else { return }
        
        let lines = logData.components(separatedBy: .newlines)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for line in lines.reversed() {
            guard !line.isEmpty else { continue }
            
            // 解析日志行
            if let timestamp = line.firstMatch(of: /\[(.*?)\]/)?.1,
               let level = line.firstMatch(of: /\[([A-Z]+)\]/)?.1,
               let date = dateFormatter.date(from: String(timestamp)),
               let logLevel = LogEntry.LogLevel(rawValue: String(level)) {
                
                let messageStart = line.range(of: "] ", options: .backwards)?.upperBound ?? line.startIndex
                let message = String(line[messageStart...]).trimmingCharacters(in: .whitespaces)
                
                let entry = LogEntry(timestamp: date, level: logLevel, message: message)
                logs.append(entry)
                
                if logs.count >= maxLogEntries {
                    break
                }
            }
        }
    }
    
    func exportLogs() -> URL {
        return logFileURL
    }
}
