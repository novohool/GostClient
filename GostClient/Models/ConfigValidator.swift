import Foundation

enum ConfigValidationError: LocalizedError {
    case invalidServerAddress
    case invalidServerPort
    case invalidLocalPort
    case emptyCredentials
    case invalidRulePattern
    case incompatibleVersion
    case invalidYAMLFormat
    case invalidJSONFormat
    
    var errorDescription: String? {
        switch self {
        case .invalidServerAddress:
            return "服务器地址无效。请输入有效的域名或IP地址"
        case .invalidServerPort:
            return "服务器端口无效。端口范围应为1-65535"
        case .invalidLocalPort:
            return "本地端口无效。端口范围应为1-65535"
        case .emptyCredentials:
            return "用户名或密码不能为空"
        case .invalidRulePattern:
            return "代理规则格式无效"
        case .incompatibleVersion:
            return "配置文件版本不兼容"
        case .invalidYAMLFormat:
            return "YAML格式无效"
        case .invalidJSONFormat:
            return "JSON格式无效"
        }
    }
}

struct ConfigValidator {
    static func validate(_ config: ProxyConfig) throws {
        // 验证服务器配置
        try validateServerConfig(config.serverConfig)
        
        // 验证代理设置
        try validateProxySettings(config.proxySettings)
        
        // 验证规则
        try validateRules(config.rules)
        
        // 验证版本兼容性
        try validateVersion(config.version)
    }
    
    static func validateServerConfig(_ config: ProxyConfig.ServerConfig) throws {
        // 验证服务器地址
        guard isValidHostname(config.serverAddress) else {
            throw ConfigValidationError.invalidServerAddress
        }
        
        // 验证服务器端口
        guard isValidPort(config.serverPort) else {
            throw ConfigValidationError.invalidServerPort
        }
        
        // 验证认证信息
        guard !config.username.isEmpty && !config.password.isEmpty else {
            throw ConfigValidationError.emptyCredentials
        }
    }
    
    static func validateProxySettings(_ settings: ProxyConfig.ProxySettings) throws {
        // 验证本地端口
        guard isValidPort(settings.localPort) else {
            throw ConfigValidationError.invalidLocalPort
        }
    }
    
    static func validateRules(_ rules: [ProxyRule]) throws {
        // 验证每个规则的格式
        for rule in rules {
            guard isValidRulePattern(rule.pattern) else {
                throw ConfigValidationError.invalidRulePattern
            }
        }
    }
    
    static func validateVersion(_ version: String) throws {
        // 验证版本兼容性
        let supportedVersions = ["1.0"]
        guard supportedVersions.contains(version) else {
            throw ConfigValidationError.incompatibleVersion
        }
    }
    
    static func validateYAMLString(_ yaml: String) throws {
        // 验证YAML格式
        // 这里可以添加更详细的YAML格式验证
        guard !yaml.isEmpty else {
            throw ConfigValidationError.invalidYAMLFormat
        }
    }
    
    // MARK: - Helper Methods
    
    private static func isValidHostname(_ hostname: String) -> Bool {
        // 验证域名或IP地址格式
        let hostnameRegex = "^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$"
        let ipRegex = "^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$"
        
        let hostnamePredicate = NSPredicate(format: "SELF MATCHES %@", hostnameRegex)
        let ipPredicate = NSPredicate(format: "SELF MATCHES %@", ipRegex)
        
        return hostnamePredicate.evaluate(with: hostname) || ipPredicate.evaluate(with: hostname)
    }
    
    private static func isValidPort(_ port: Int) -> Bool {
        return port > 0 && port <= 65535
    }
    
    private static func isValidRulePattern(_ pattern: String) -> Bool {
        // 验证规则格式
        // 这里实现具体的规则格式验证逻辑
        // 例如：域名通配符、IP范围等
        guard !pattern.isEmpty else { return false }
        
        // 检查基本的通配符格式
        let validCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._*?")
        return pattern.unicodeScalars.allSatisfy { validCharacters.contains($0) }
    }
}
