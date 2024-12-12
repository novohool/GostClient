import SwiftUI
import NetworkExtension

struct VPNManagementView: View {
    @StateObject private var viewModel = GostViewModel()
    @State private var showingError = false
    @State private var isInstalling = false

    var body: some View {
        VStack {
            Text("VPN 描述文件管理").font(.largeTitle).padding()
            Button("检查并安装 VPN 描述文件") {
                isInstalling = true
                do {
                    try viewModel.checkAndInstallVPNProfile()
                } catch {
                    showingError = true
                    viewModel.errorMessage = error.localizedDescription
                }
                isInstalling = false
            }
            .disabled(isInstalling) // 禁用按钮在安装过程中
            .overlay(
                Group {
                    if isInstalling {
                        ProgressView("安装中...")
                    }
                }
            )
            .alert("错误", isPresented: $showingError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("VPN 管理")
        .onAppear {
            // 自动检查 VPN 描述文件的安装状态
            viewModel.checkAndInstallVPNProfile()
        }
        .onDisappear {
            // 自动检查 VPN 描述文件的安装状态，当用户返回应用时
            viewModel.checkAndInstallVPNProfile()
        }
    }
}
