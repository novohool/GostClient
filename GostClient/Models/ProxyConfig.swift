import Foundation

struct ProxyConfig: Codable {
    var serverAddress: String = ""
    var username: String = ""
    var password: String = ""
    var localPort: Int = 1080
    var isEnabled: Bool = false  // 添加代理开关
    
    // 生成YAML配置
    func generateYAMLConfig() -> String {
        """
        services:
        - name: service-0
          addr: :\(localPort)
          handler:
            type: socks5
            chain: chain-0
          listener:
            type: tcp
        
        chains:
        - name: chain-0
          hops:
          - name: hop-0
            nodes:
            - name: node-0
              addr: \(serverAddress)
              connector:
                type: mwss
                metadata:
                  host: \(serverAddress.components(separatedBy: ":").first ?? "")
                  path: "/ws"
                  header: {}
        """
    }
    
    // 验证配置是否完整
    var isConfigValid: Bool {
        return !serverAddress.isEmpty && !username.isEmpty && !password.isEmpty
    }
    
    // 保存配置到文件
    func saveToFile(_ path: String) throws {
        let yaml = generateYAMLConfig()
        try yaml.write(toFile: path, atomically: true, encoding: .utf8)
    }
}

class ProxyConfigManager: ObservableObject {
    static let shared = ProxyConfigManager()
    
    @Published var config: ProxyConfig {
        didSet {
            saveConfig()
            if config.isConfigValid {
                // 只有在配置有效时才更新配置文件
                do {
                    try config.saveToFile(configFilePath)
                } catch {
                    print("Error saving config file: \(error)")
                }
            }
        }
    }
    
    private let configKey = "ProxyConfig"
    private let configFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("gost.yaml").path
    
    init() {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let savedConfig = try? JSONDecoder().decode(ProxyConfig.self, from: data) {
            config = savedConfig
        } else {
            config = ProxyConfig()
        }
        
        // 只有在配置有效时才创建配置文件
        if config.isConfigValid {
            do {
                try config.saveToFile(configFilePath)
            } catch {
                print("Error creating initial config file: \(error)")
            }
        }
    }
    
    private func saveConfig() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }
    
    var configFileURL: URL {
        URL(fileURLWithPath: configFilePath)
    }
}
