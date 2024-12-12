import SwiftUI

struct LaunchConfigView: View {
    @StateObject private var configManager = LaunchConfigManager.shared
    
    var body: some View {
        Form {
            // 基本设置
            Section(header: Text("基本设置")) {
                TextField("配置文件", text: $configManager.config.configFile)
                    .autocapitalization(.none)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Text("YAML配置文件路径")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Toggle("调试模式", isOn: $configManager.config.debug)
                Toggle("显示版本", isOn: $configManager.config.version)
            }
            
            // 预览
            Section(header: Text("启动命令预览")) {
                Text("gost " + configManager.config.buildArguments().joined(separator: " "))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .padding(.vertical, 8)
            }
        }
        .navigationTitle("启动参数配置")
    }
}
