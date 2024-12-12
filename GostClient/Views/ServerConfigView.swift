import SwiftUI

// 服务器配置视图
struct ServerConfigView: View {
    // 共享的代理配置管理器
    @StateObject private var configManager = ProxyConfigManager.shared
    
    var body: some View {
        // 表单视图
        Form {
            // 服务器配置部分
            Section(header: Text("服务器配置").frame(maxWidth: .infinity, alignment: .leading)) {
                // 服务器地址输入框
                TextField("服务器地址", text: $configManager.config.serverAddress)
                    .autocapitalization(.none)
                    .disabled(configManager.config.isEnabled) // 代理开启时禁用
                
                // 端口输入框
                TextField("端口", value: $configManager.config.localPort, formatter: NumberFormatter())
                    .keyboardType(.numberPad)
                    .disabled(configManager.config.isEnabled) // 代理开启时禁用
            }
            
            // 认证信息部分
            Section(header: Text("认证信息").frame(maxWidth: .infinity, alignment: .leading)) {
                // 用户名输入框
                TextField("用户名", text: $configManager.config.authUsername)
                    .autocapitalization(.none)
                    .disabled(configManager.config.isEnabled) // 代理开启时禁用
                
                // 密码输入框
                SecureField("密码", text: $configManager.config.authPassword)
                    .disabled(configManager.config.isEnabled) // 代理开启时禁用
            }
        }
        // 导航标题
        .navigationTitle("服务器设置")
    }
}
