import SwiftUI

struct LogViewer: View {
    @StateObject private var logManager = LogManager.shared
    @State private var selectedLevels: Set<LogEntry.LogLevel> = Set(LogEntry.LogLevel.allCases)
    @State private var searchText = ""
    @State private var showingShareSheet = false
    
    var filteredLogs: [LogEntry] {
        logManager.logs.filter { log in
            let matchesLevel = selectedLevels.contains(log.level)
            let matchesSearch = searchText.isEmpty || 
                log.message.localizedCaseInsensitiveContains(searchText)
            return matchesLevel && matchesSearch
        }
    }
    
    var body: some View {
        VStack {
            // 过滤器
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(LogEntry.LogLevel.allCases, id: \.self) { level in
                        FilterChip(
                            title: level.rawValue,
                            isSelected: selectedLevels.contains(level),
                            color: Color(level.color)
                        ) {
                            if selectedLevels.contains(level) {
                                selectedLevels.remove(level)
                            } else {
                                selectedLevels.insert(level)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // 搜索栏
            TextField("搜索日志", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // 日志列表
            List(filteredLogs) { log in
                LogEntryRow(log: log)
            }
        }
        .navigationTitle("日志查看")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { logManager.clearLogs() }) {
                        Label("清除日志", systemImage: "trash")
                    }
                    
                    Button(action: { showingShareSheet = true }) {
                        Label("导出日志", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [logManager.exportLogs()])
        }
    }
}

struct LogEntryRow: View {
    let log: LogEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(formatDate(log.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(log.level.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color(log.level.color).opacity(0.2))
                    .foregroundColor(Color(log.level.color))
                    .cornerRadius(4)
            }
            
            Text(log.message)
                .font(.body)
                .lineLimit(nil)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? color.opacity(0.2) : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? color : .gray)
                .cornerRadius(16)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
