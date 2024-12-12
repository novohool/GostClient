import SwiftUI

struct BinaryManagementView: View {
    @StateObject private var binaryManager = GostBinaryManager.shared
    @State private var showingError = false
    
    @ViewBuilder
    private func statusView() -> some View {
        if binaryManager.isDownloading {
            ProgressView("下载中...", value: binaryManager.downloadProgress, total: 1.0)
        } else if binaryManager.isInstalled {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("已安装")
            }
        } else {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
                Text("未安装")
                Spacer()
                Button("安装") {
                    do {
                        try binaryManager.checkAndInstallBinary()
                    } catch {
                        showingError = true
                        binaryManager.error = error.localizedDescription
                    }
                }
                .alert("错误", isPresented: $showingError) {
                    Button("确定", role: .cancel) {}
                } message: {
                    Text(binaryManager.error)
                }
            }
        }
    }
    
    var body: some View {
        List {
            Section(header: Text("GOST 二进制")) {
                statusView() // 使用提取的方法
                if binaryManager.isRunning {
                    Text("正在运行")
                } else {
                    Text("已停止")
                }
                
                // 更新连接状态反馈
                Text(binaryManager.isConnected ? "VPN 连接状态: 已连接" : "VPN 连接状态: 未连接")
                    .foregroundColor(binaryManager.isConnected ? .green : .red)
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
                                do {
                                    try binaryManager.startGost(configPath: configPath)
                                    binaryManager.isRunning = true // 更新运行状态
                                } catch {
                                    showingError = true
                                    binaryManager.error = error.localizedDescription // 记录错误信息
                                }
                            } catch {
                                showingError = true
                                binaryManager.error = error.localizedDescription // 记录错误信息
                            }
                        }) {
                            Label("启动服务", systemImage: "play.fill")
                                .foregroundColor(.green)
                        }
                        .alert("错误", isPresented: $showingError) {
                            Button("确定", role: .cancel) {}
                        } message: {
                            Text(binaryManager.error)
                        }
                    }
                }
            }
        }
        .navigationTitle("二进制管理")
        .alert("错误", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(binaryManager.error)
        }
    }
}
