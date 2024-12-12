import SwiftUI

struct ConfigurationView: View {
    @StateObject private var configManager = ProxyConfigManager.shared
    @State private var isEditingCredentials = false
    
    var body: some View {
        Form {
            Section {
                Toggle("启用代理", isOn: $configManager.config.isEnabled)
                    .tint(.blue)
            }
            
            Section(header: Text("服务器设置").frame(maxWidth: .infinity, alignment: .leading)) {
                TextField("服务器地址", text: $configManager.config.serverAddress)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("格式: host:port (例如: example.com:443)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if isEditingCredentials {
                    TextField("用户名", text: $configManager.config.username)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("密码", text: $configManager.config.password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("保存", action: {
                        isEditingCredentials = false
                    })
                } else {
                    HStack {
                        Text("用户名: \(configManager.config.username)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Button("编辑", action: {
                            isEditingCredentials = true
                        })
                    }
                    HStack {
                        Text("密码: \(configManager.config.password.isEmpty ? "未设置" : "已设置")")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Spacer()
                        Button("编辑", action: {
                            isEditingCredentials = true
                        })
                    }
                }
            }
            .disabled(!configManager.config.isEnabled)
            
            Section(header: Text("本地设置").frame(maxWidth: .infinity, alignment: .leading)) {
                TextField("本地端口", value: $configManager.config.localPort, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("SOCKS5 代理端口 (默认: 1080)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .disabled(!configManager.config.isEnabled)
            
            if configManager.config.isEnabled && configManager.config.isConfigValid {
                Section(header: Text("配置预览").frame(maxWidth: .infinity, alignment: .leading)) {
                    Text(configManager.config.generateYAMLConfig())
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("代理配置")
    }
}
