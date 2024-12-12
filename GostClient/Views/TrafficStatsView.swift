import SwiftUI

struct TrafficStats {
    var bytesIn: Int64
    var bytesOut: Int64
    var uptime: TimeInterval
}

struct TrafficStatsView: View {
    @StateObject private var viewModel = TrafficStatsViewModel()
    
    var body: some View {
        List {
            Section(header: Text("实时流量")) {
                HStack {
                    Image(systemName: "arrow.down.circle.fill")
                        .foregroundColor(.blue)
                    VStack(alignment: .leading) {
                        Text("下载")
                            .font(.caption)
                        Text(formatBytes(viewModel.stats.bytesIn))
                            .font(.title2)
                    }
                }
                
                HStack {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundColor(.green)
                    VStack(alignment: .leading) {
                        Text("上传")
                            .font(.caption)
                        Text(formatBytes(viewModel.stats.bytesOut))
                            .font(.title2)
                    }
                }
                
                HStack {
                    Image(systemName: "clock")
                    VStack(alignment: .leading) {
                        Text("运行时间")
                            .font(.caption)
                        Text(formatDuration(viewModel.stats.uptime))
                            .font(.title2)
                    }
                }
            }
            
            Section(header: Text("图表")) {
                // 这里可以添加流量图表
                Text("流量趋势图")
                    .frame(height: 200)
            }
        }
        .navigationTitle("流量统计")
        .onAppear {
            viewModel.startUpdatingStats()
        }
        .onDisappear {
            viewModel.stopUpdatingStats()
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? "0s"
    }
}

class TrafficStatsViewModel: ObservableObject {
    @Published var stats = TrafficStats(bytesIn: 0, bytesOut: 0, uptime: 0)
    private var timer: Timer?
    
    func startUpdatingStats() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
    }
    
    func stopUpdatingStats() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateStats() {
        // 从 PacketTunnelProvider 获取实时流量统计
        // 这里需要实现与 PacketTunnelProvider 的通信
    }
}
