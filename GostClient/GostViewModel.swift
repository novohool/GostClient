import Foundation
import Network
import Archive // Make sure to import the Archive library
import NetworkExtension
import Security

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
    
    private var tunnel: NWConnection?
    
    func connect() {
        checkAndInstallVPNProfile() // 检查并安装 VPN 描述文件
        useLocalBinary() // 启动本地 GOST
        addLog("正在连接到代理服务器...")
        let proxyUrl = URL(string: "socks5://\(proxyServer):\(proxyPort)")! // 更新为 SOCKS5 代理
        let proxyConfig = NWProxySettings()
        proxyConfig.socksEnabled = true // 启用 SOCKS 代理
        proxyConfig.socksProxy = proxyUrl
        let parameters = NWParameters()
        parameters.proxySettings = proxyConfig

        // 创建连接实例
        tunnel = NWConnection(to: NWEndpoint.hostPort(host: proxyServer, port: UInt16(proxyPort)), using: parameters)
        tunnel?.stateUpdateHandler = { [weak self] newState in
            switch newState {
            case .ready:
                self?.isConnected = true
                self?.addLog("代理隧道连接成功")
            case .failed(let error):
                self?.addLog("连接失败: \(error.localizedDescription) - \(String(describing: error)) - \(error)")
                self?.showErrorMessage("代理隧道连接失败: \(error.localizedDescription) - \(String(describing: error)) - \(error)")
            case .cancelled:
                self?.addLog("代理隧道连接已取消")
            default:
                break
            }
        }
        tunnel?.start(queue: .main)
    }
    
    func disconnect() {
        tunnel?.cancel()
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
    
    func useLocalBinary() {
        let fileManager = FileManager.default
        let binaryPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Binaries/gost")
        if fileManager.fileExists(atPath: binaryPath.path) {
            self.addLog("使用本地 GOST 文件: \(binaryPath.path)")
            // 在这里添加使用 GOST 文件的逻辑
            // 例如：执行 GOST 文件
            let task = Process()
            task.launchPath = binaryPath.path
            task.arguments = ["-L", "\(proxyServer):\(proxyPort)", "-F", "\(username):\(password)"]
            task.launch()
            self.addLog("GOST 文件已启动")
        } else {
            self.showErrorMessage("本地 GOST 文件不存在")
        }
    }
    
    private func extractFile(at location: URL) {
        let fileManager = FileManager.default
        let destinationURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("gost")
        do {
            // 创建目标目录
            try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            // 解压缩逻辑
            let fileData = try Data(contentsOf: location)
            let archive = try Archive(data: fileData, accessMode: .read)
            for entry in archive { 
                let entryURL = destinationURL.appendingPathComponent(entry.path)
                try archive.extract(entry, to: entryURL)
            }
            self.addLog("gost 文件已解压到: \(destinationURL.path)")
        } catch {
            self.showErrorMessage("解压缩失败: \(error.localizedDescription)")
        }
    }
    
    // 添加 VPN 描述文件检查和安装逻辑
    func checkAndInstallVPNProfile() {
        let vpnManager = NEVPNManager.shared()
        vpnManager.loadFromPreferences { [weak self] error in
            if let error = error {
                self?.showErrorMessage("加载 VPN 配置失败: \(error.localizedDescription)")
                return
            }

            if vpnManager.protocolConfiguration == nil {
                // VPN 描述文件未安装，跳转到设置页面
                DispatchQueue.main.async {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            } else {
                self?.addLog("VPN 描述文件已安装")
                // 不需要跳转到设置页面
            }
        }
    }

    private func installVPNProfile() {
        // 在这里实现安装 VPN 描述文件的逻辑
        let vpnManager = NEVPNManager.shared()
        let vpnProtocol = NEVPNProtocolIPSec()
        if let password = retrievePasswordFromKeychain() {
            vpnProtocol.passwordReference = password.data(using: .utf8)
        } else {
            vpnProtocol.passwordReference = password.data(using: .utf8)
            storePasswordInKeychain(password: password)
        }
        vpnProtocol.username = self.username
        vpnProtocol.serverAddress = self.proxyServer
        vpnProtocol.authenticationMethod = .password
        vpnManager.protocolConfiguration = vpnProtocol
        vpnManager.isEnabled = true

        vpnManager.saveToPreferences { [weak self] error in
            if let error = error {
                self?.showErrorMessage("安装 VPN 描述文件失败: \(error.localizedDescription)")
            } else {
                self?.addLog("VPN 描述文件安装成功")
                DispatchQueue.main.async {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
    }
    
    // 添加 Keychain 存储逻辑
    private func storePasswordInKeychain(password: String) {
        let passwordData = password.data(using: .utf8)! 
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecValueData as String: passwordData
        ]
        SecItemDelete(query as CFDictionary) // 删除旧的密码
        SecItemAdd(query as CFDictionary, nil) // 添加新的密码
    }

    private func retrievePasswordFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: username,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject? = nil
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess {
            if let passwordData = dataTypeRef as? Data {
                return String(data: passwordData, encoding: .utf8)
            }
        }
        return nil
    }
}
