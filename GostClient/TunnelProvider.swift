import NetworkExtension

class TunnelProvider: NEPacketTunnelProvider {
    private var socksProxy: NWConnection?

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        // 在这里实现启动隧道的逻辑
        // 例如：配置网络设置，启动流量转发等
        let proxyHost = "\(self.providerConfiguration["SocksProxyHost"] ?? "localhost")"
        let proxyPort = Int(self.providerConfiguration["SocksProxyPort"] ?? "1080") ?? 1080
        let endpoint = NWEndpoint.hostPort(host: proxyHost, port: NWEndpoint.Port(rawValue: UInt16(proxyPort))!)

        socksProxy = NWConnection(to: endpoint, using: .tcp)
        socksProxy?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.startReceivingPackets()
            case .failed(let error):
                self?.stopTunnel(with: .unknown, completionHandler: {})
                print("Socks proxy connection failed: \(error)")
            default:
                break
            }
        }
        socksProxy?.start(queue: .main)
        completionHandler(nil) // 成功启动隧道
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        socksProxy?.cancel()
        completionHandler() // 成功停止隧道
    }

    override func packetReceived(_ packet: Data) {
        // 处理接收到的流量包并转发到 SOCKS5 代理
        socksProxy?.send(content: packet, completion: .contentProcessed({ error in
            if let error = error {
                print("Error sending packet: \(error)")
            }
        }))
    }

    override func sendPacket(_ packet: Data) {
        // 处理从 SOCKS5 代理接收到的流量包
        self.packetReceived(packet)
    }
}
