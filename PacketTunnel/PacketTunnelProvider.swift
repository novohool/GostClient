import NetworkExtension
import os.log

class PacketTunnelProvider: NEPacketTunnelProvider {
    private let logger = Logger(subsystem: "com.gost.client", category: "PacketTunnelProvider")
    private let gostManager = GostBinaryManager.shared
    private let configManager = ProxyConfigManager.shared
    
    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        logger.info("Starting tunnel...")
        
        // 检查代理是否启用
        guard configManager.config.isEnabled else {
            logger.info("Proxy is disabled, not starting tunnel")
            completionHandler(nil)
            return
        }
        
        // 检查配置是否有效
        guard configManager.config.isConfigValid else {
            let error = NSError(domain: "ProxyError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid proxy configuration"])
            logger.error("Invalid configuration")
            completionHandler(error)
            return
        }
        
        // 1. 设置网络配置
        let networkSettings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        networkSettings.mtu = 1500
        
        // 配置代理设置
        let proxySettings = NEProxySettings()
        proxySettings.matchDomains = [""] // 匹配所有域名
        
        // SOCKS代理设置
        proxySettings.autoproxyConfigurationEnabled = false
        proxySettings.proxyAutoConfigurationEnabled = false
        proxySettings.proxyAutoConfigurationJavaScript = nil
        proxySettings.excludeSimpleHostnames = true
        
        proxySettings.httpEnabled = false
        proxySettings.httpsEnabled = false
        proxySettings.httpServer = nil
        proxySettings.httpsServer = nil
        
        let port = configManager.config.localPort
        proxySettings.matchDomains = [""]
        proxySettings.exceptionList = []
        
        // 设置SOCKS代理服务器
        let socksProxy = NEProxyServer(address: "127.0.0.1", port: Int(port))
        proxySettings.socksServers = [socksProxy]
        proxySettings.socksEnabled = true
        
        networkSettings.proxySettings = proxySettings
        
        // 2. 应用网络设置
        setTunnelNetworkSettings(networkSettings) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.logger.error("Failed to set tunnel network settings: \(error.localizedDescription)")
                completionHandler(error)
                return
            }
            
            // 3. 检查并安装GOST
            Task {
                do {
                    try await self.gostManager.checkAndInstallBinary()
                    
                    // 4. 启动GOST
                    try self.gostManager.startGost(configPath: self.configManager.configFileURL.path)
                    self.logger.info("GOST started successfully")
                    completionHandler(nil)
                } catch {
                    self.logger.error("Failed to start GOST: \(error.localizedDescription)")
                    completionHandler(error)
                }
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        logger.info("Stopping tunnel...")
        
        // 停止GOST
        do {
            try gostManager.stopGost()
            logger.info("GOST stopped successfully")
        } catch {
            logger.error("Failed to stop GOST: \(error.localizedDescription)")
        }
        
        completionHandler()
    }
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // 处理来自主应用的消息
        if let message = String(data: messageData, encoding: .utf8) {
            logger.debug("Received message from app: \(message)")
        }
        completionHandler?(nil)
    }
}
