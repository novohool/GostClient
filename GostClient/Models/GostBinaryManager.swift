import Foundation
import os.log

class GostBinaryManager {
    static let shared = GostBinaryManager()
    private let logger = Logger(subsystem: "com.gost.client", category: "GostBinaryManager")
    
    private var process: Process?
    private let binaryName = "gost"
    
    private var binaryPath: URL {
        // 获取应用程序支持目录
        let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupportURL.appendingPathComponent(binaryName)
    }
    
    private var workingDirectory: URL {
        // 使用应用程序支持目录作为工作目录
        return FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
    }
    
    var isRunning: Bool {
        return process != nil && process!.isRunning
    }
    
    var isInstalled: Bool {
        return FileManager.default.fileExists(atPath: binaryPath.path)
    }
    
    func startGost(configPath: String) throws {
        guard isInstalled else {
            logger.error("GOST binary not installed")
            throw NSError(domain: "GostError", code: 1, userInfo: [NSLocalizedDescriptionKey: "GOST binary not installed"])
        }
        
        guard !isRunning else { return }
        
        // 确保配置文件存在
        guard FileManager.default.fileExists(atPath: configPath) else {
            logger.error("Config file not found: \(configPath)")
            throw NSError(domain: "GostError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Config file not found"])
        }
        
        let process = Process()
        process.executableURL = binaryPath
        process.arguments = ["-C", configPath]
        process.currentDirectoryURL = workingDirectory
        
        logger.info("Starting GOST with config: \(configPath)")
        
        // 设置输出管道
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // 处理输出
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            guard let data = try? handle.read(upToCount: 1024),
                  let output = String(data: data, encoding: .utf8) else { return }
            self?.logger.debug("GOST output: \(output)")
        }
        
        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            guard let data = try? handle.read(upToCount: 1024),
                  let output = String(data: data, encoding: .utf8) else { return }
            self?.logger.error("GOST error: \(output)")
        }
        
        // 启动进程
        try process.run()
        self.process = process
        
        logger.info("GOST started successfully")
    }
    
    func stopGost() throws {
        guard let process = process, process.isRunning else { return }
        
        logger.info("Stopping GOST")
        process.terminate()
        self.process = nil
        logger.info("GOST stopped")
    }
    
    func installBinary(from url: URL) throws {
        logger.info("Installing GOST binary from: \(url.path)")
        
        // 创建目标目录
        try FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: true)
        
        // 复制二进制文件
        if FileManager.default.fileExists(atPath: binaryPath.path) {
            try FileManager.default.removeItem(at: binaryPath)
        }
        try FileManager.default.copyItem(at: url, to: binaryPath)
        
        // 设置执行权限
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: binaryPath.path)
        
        logger.info("GOST binary installed successfully")
    }
    
    func checkAndInstallBinary() async throws {
        // 如果已经安装，直接返回
        guard !isInstalled else { return }
        
        logger.info("Binary not found, starting installation...")
        
        // 这里应该从你的服务器或者资源包中获取二进制文件
        // 示例使用本地资源包中的二进制文件
        guard let binaryURL = Bundle.main.url(forResource: binaryName, withExtension: nil) else {
            throw NSError(domain: "GostError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Binary not found in bundle"])
        }
        
        try installBinary(from: binaryURL)
    }
}
