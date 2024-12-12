import SwiftUI

struct BinaryManagementView: View {
    @StateObject private var binaryManager = GostBinaryManager.shared
    @State private var showingError = false
    
    @ViewBuilder
    private func statusView() -> some View {
        if binaryManager.isDownloading {
            ProgressView("下载中...", value: binaryManager.downloadProgress, total: 1.0)
                .foregroundColor(Color.blue)
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(8)
                .shadow(radius: 3)
        } else if binaryManager.isInstalled {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("已安装")
            }
            .foregroundColor(Color.green)
            .padding()
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
            .shadow(radius: 3)
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
            .foregroundColor(Color.red)
            .padding()
            .background(Color.red.opacity(0.2))
            .cornerRadius(8)
            .shadow(radius: 3)
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
                            showingError = false // Reset error state
                            let configPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                                .appendingPathComponent("gost.yaml")
                                .path
                            do {
                                try binaryManager.startGost(configPath: configPath)
                                binaryManager.isRunning = true
                            } catch {
                                showingError = true
                                binaryManager.error = error.localizedDescription
                            }
                        }) {
                            Label(binaryManager.isRunning ? "停止服务" : "启动服务", systemImage: binaryManager.isRunning ? "stop.fill" : "play.fill")
                                .foregroundColor(binaryManager.isRunning ? .red : .green)
                                .padding()
                                .background(binaryManager.isRunning ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                                .cornerRadius(8)
                                .shadow(radius: 3)
                        }
                        .accessibilityLabel(binaryManager.isRunning ? "停止 GOST 服务" : "启动 GOST 服务")
                        .alert("错误", isPresented: $showingError) {
                            Button("确定", role: .cancel) {}
                        } message: {
                            Text(binaryManager.error)
                        }
                    }
                    Button(binaryManager.isRunning ? "停止" : "启动") {
                        if binaryManager.isRunning {
                            binaryManager.stopBinary() // 停止代理
                        } else {
                            do {
                                try binaryManager.startBinary() // 启动代理
                            } catch {
                                showingError = true
                                binaryManager.error = error.localizedDescription
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .alert("错误", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(binaryManager.error)
        }
        .navigationTitle("二进制管理")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Action to refresh or perform another task
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .padding()
    }
}
