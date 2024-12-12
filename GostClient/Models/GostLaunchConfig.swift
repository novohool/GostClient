import Foundation

struct GostLaunchConfig: Codable {
    // 基本参数
    var configFile: String = "gost.yaml"
    var debug: Bool = false
    var version: Bool = false
    
    // 构建启动参数数组
    func buildArguments() -> [String] {
        var args: [String] = []
        
        // 配置文件
        if !configFile.isEmpty {
            args.append("-C")
            args.append(configFile)
        }
        
        // 调试模式
        if debug {
            args.append("-D")
        }
        
        // 版本信息
        if version {
            args.append("-V")
        }
        
        return args
    }
}

class LaunchConfigManager: ObservableObject {
    static let shared = LaunchConfigManager()
    
    @Published var config: GostLaunchConfig {
        didSet {
            saveConfig()
        }
    }
    
    private let configKey = "GostLaunchConfig"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: configKey),
           let savedConfig = try? JSONDecoder().decode(GostLaunchConfig.self, from: data) {
            config = savedConfig
        } else {
            config = GostLaunchConfig()
        }
    }
    
    private func saveConfig() {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: configKey)
        }
    }
}
