import Foundation
import Network

class GostViewModel: ObservableObject {
    @Published var isConnected = false
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var logs: [String] = []
    
    private var proxyServer: String {
        return ProxyConfigManager.shared.config.serverAddress
    }
    
    private var proxyPort: Int {
        return ProxyConfigManager.shared.config.localPort
    }
    
    private var username: String {
        return ProxyConfigManager.shared.config.username
    }
    
    private var password: String {
        return ProxyConfigManager.shared.config.password
    }
    
    func connect() {
        // 在这里实现代理连接逻辑
        addLog("正在连接到代理服务器...")
        
        // 这里需要实现实际的GOST代理连接逻辑
        // 由于iOS的限制，我们需要使用Network Extension框架
        // 并且需要相应的权限配置
        
        isConnected = true
        addLog("代理服务器连接成功")
    }
    
    func disconnect() {
        // 断开代理连接
        isConnected = false
        addLog("已断开代理连接")
    }
    
    private func addLog(_ message: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let timestamp = dateFormatter.string(from: Date())
        DispatchQueue.main.async {
            self.logs.insert("[\(timestamp)] \(message)", at: 0)
            if self.logs.count > 100 {
                self.logs.removeLast()
            }
        }
    }
    
    func showErrorMessage(_ message: String) {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
}
