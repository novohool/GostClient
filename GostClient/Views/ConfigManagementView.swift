import SwiftUI
import UniformTypeIdentifiers

struct ConfigManagementView: View {
    @StateObject private var configManager = ConfigManager.shared
    @State private var showingExportOptions = false
    @State private var showingImportPicker = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var exportFormat: ExportFormat = .json
    
    enum ExportFormat {
        case json
        case yaml
    }
    
    var body: some View {
        List {
            Section(header: Text("配置管理")) {
                Button(action: { showingExportOptions = true }) {
                    Label("导出配置", systemImage: "square.and.arrow.up")
                }
                
                Button(action: { showingImportPicker = true }) {
                    Label("导入配置", systemImage: "square.and.arrow.down")
                }
            }
            
            Section(header: Text("当前配置")) {
                ConfigDetailRow(title: "服务器", value: configManager.currentConfig.serverConfig.serverAddress)
                ConfigDetailRow(title: "端口", value: "\(configManager.currentConfig.serverConfig.serverPort)")
                ConfigDetailRow(title: "本地端口", value: "\(configManager.currentConfig.proxySettings.localPort)")
                ConfigDetailRow(title: "规则数量", value: "\(configManager.currentConfig.rules.count)")
            }
        }
        .navigationTitle("配置管理")
        .confirmationDialog("选择导出格式", isPresented: $showingExportOptions) {
            Button("导出为 JSON") {
                exportFormat = .json
                exportConfig()
            }
            Button("导出为 YAML") {
                exportFormat = .yaml
                exportConfig()
            }
            Button("取消", role: .cancel) {}
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                importConfig(from: url)
            case .failure(let error):
                showError("导入失败: \(error.localizedDescription)")
            }
        }
        .alert("错误", isPresented: $showingError) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }
    
    private func exportConfig() {
        do {
            let data: Data
            let filename: String
            
            switch exportFormat {
            case .json:
                data = try configManager.exportConfig()
                filename = "gost_config.json"
            case .yaml:
                let yamlString = try configManager.exportConfigAsYAML()
                try ConfigValidator.validateYAMLString(yamlString)
                data = yamlString.data(using: .utf8) ?? Data()
                filename = "gost.yaml"
            }
            
            // 保存到文档目录
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsPath.appendingPathComponent(filename)
            try data.write(to: fileURL)
            
            // 分享文件
            let activityVC = UIActivityViewController(
                activityItems: [fileURL],
                applicationActivities: nil
            )
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootVC = window.rootViewController {
                rootVC.present(activityVC, animated: true)
            }
        } catch let error as ConfigValidationError {
            showError(error.localizedDescription)
        } catch {
            showError("导出失败: \(error.localizedDescription)")
        }
    }
    
    private func importConfig(from url: URL) {
        do {
            let data = try Data(contentsOf: url)
            try configManager.importConfig(from: data)
        } catch let error as ConfigValidationError {
            showError(error.localizedDescription)
        } catch let error as DecodingError {
            showError("配置格式无效: \(error.localizedDescription)")
        } catch {
            showError("导入失败: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
}

struct ConfigDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

// 扩展 UTType 以支持自定义文件类型
extension UTType {
    static var gostConfig: UTType {
        UTType(importedAs: "com.gostclient.config")
    }
}
