import SwiftUI

struct BinaryManagementView: View {
    @StateObject private var binaryManager = GostBinaryManager.shared
    @State private var showingError = false
    
    var body: some View {
        List {
            Section(header: Text("GOST 二进制")) {
                if binaryManager.isDownloading {
                    ProgressView("下载中...", value: binaryManager.downloadProgress, total: 1.0)
                } else {
                    HStack {
                        Image(systemName: binaryManager.isInstalled ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(binaryManager.isInstalled ? .green : .red)
                        Text(binaryManager.isInstalled ? "已安装" : "未安装")
                        
                        if !binaryManager.isInstalled {
                            Spacer()
                            Button("安装") {
                                Task {
                                    do {
                                        try await binaryManager.downloadAndInstall()
                                    } catch {
                                        showingError = true
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: binaryManager.isRunning ? "play.circle.fill" : "stop.circle.fill")
                            .foregroundColor(binaryManager.isRunning ? .green : .red)
                        Text(binaryManager.isRunning ? "运行中" : "已停止")
                    }
                }
            }
            
            if binaryManager.isInstalled {
                Section(header: Text("操作")) {
                    if binaryManager.isRunning {
                        Button(action: {
                            binaryManager.stopGost()
                        }) {
                            Label("停止服务", systemImage: "stop.fill")
                                .foregroundColor(.red)
                        }
                    } else {
                        Button(action: {
                            do {
                                // 获取配置文件路径
                                let configPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                    .appendingPathComponent("gost.yaml")
                                    .path
                                try binaryManager.startGost(configPath: configPath)
                            } catch {
                                showingError = true
                            }
                        }) {
                            Label("启动服务", systemImage: "play.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .navigationTitle("二进制管理")
        .alert("错误", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(binaryManager.error ?? "未知错误")
        }
    }
}
