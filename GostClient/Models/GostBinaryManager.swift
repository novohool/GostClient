import Foundation
import os.log

class GostBinaryManager {
    static let shared = GostBinaryManager()
    private let logger = Logger(subsystem: "com.gost.client", category: "GostBinaryManager")
    
    private var process: Process?
    private let binaryName = "gost"
    
    private var binaryPath: URL {
        // 获取 Binaries 目录
        let binariesURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Binaries")
        return binariesURL.appendingPathComponent(binaryName)
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

        guard !isRunning else {
            logger.info("GOST is already running")
            return
        }

        guard FileManager.default.fileExists(atPath: configPath) else {
            logger.error("Config file not found: \(configPath)")
            throw NSError(domain: "GostError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Config file not found"])
        }

        let process = Process()
        process.executableURL = binaryPath
        process.arguments = ["-C", configPath]
        process.currentDirectoryURL = workingDirectory

        logger.info("Starting GOST with config: \(configPath)")

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            if let data = try? handle.read(upToCount: 1024), let output = String(data: data, encoding: .utf8) {
                self?.logger.debug("GOST output: \(output)")
            }
        }

        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            if let data = try? handle.read(upToCount: 1024), let output = String(data: data, encoding: .utf8) {
                self?.logger.error("GOST error: \(output)")
            }
        }

        do {
            try process.run()
            self.process = process
            logger.info("GOST started successfully")
        } catch {
            logger.error("Failed to start GOST: \(error.localizedDescription)")
            throw error
        }
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
        
        try FileManager.default.createDirectory(at: workingDirectory, withIntermediateDirectories: true)
        
        if FileManager.default.fileExists(atPath: binaryPath.path) {
            try FileManager.default.removeItem(at: binaryPath)
        }
        try FileManager.default.copyItem(at: url, to: binaryPath)
        
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: binaryPath.path)
        
        logger.info("GOST binary installed successfully")
    }
    
    func checkAndInstallBinary() async throws {
        guard !isInstalled else { return }
        logger.info("Binary not found, starting installation...")

        // 直接使用 Binaries 目录中的二进制文件
        let binariesURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("Binaries")
        let binaryURL = binariesURL.appendingPathComponent(binaryName)
        guard FileManager.default.fileExists(atPath: binaryURL.path) else {
            throw NSError(domain: "GostError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Binary not found in Binaries directory"])
        }

        try installBinary(from: binaryURL)
    }
}
