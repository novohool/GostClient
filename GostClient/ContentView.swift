import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = GostViewModel()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("代理状态")) {
                    HStack {
                        Image(systemName: viewModel.isConnected ? "circle.fill" : "circle")
                            .foregroundColor(viewModel.isConnected ? .green : .red)
                        Text(viewModel.isConnected ? "已连接" : "未连接")
                    }
                    
                    Button(action: {
                        if viewModel.isConnected {
                            viewModel.disconnect()
                        } else {
                            viewModel.connect()
                        }
                    }) {
                        Text(viewModel.isConnected ? "断开连接" : "连接")
                    }
                }
                
                Section(header: Text("代理配置")) {
                    NavigationLink(destination: ServerConfigView()) {
                        HStack {
                            Image(systemName: "server.rack")
                            Text("服务器设置")
                        }
                    }
                    
                    NavigationLink(destination: ProxySettingsView()) {
                        HStack {
                            Image(systemName: "gear")
                            Text("代理设置")
                        }
                    }
                }
                
                if !viewModel.logs.isEmpty {
                    Section(header: Text("日志")) {
                        ForEach(viewModel.logs, id: \.self) { log in
                            Text(log)
                                .font(.footnote)
                        }
                    }
                }
            }
            .navigationTitle("GOST代理")
            .alert("错误", isPresented: $viewModel.showError) {
                Button("确定", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}
