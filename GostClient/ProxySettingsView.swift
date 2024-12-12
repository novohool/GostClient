import SwiftUI

struct ProxySettingsView: View {
    @AppStorage("localPort") private var localPort = "1080"
    @AppStorage("autoConnect") private var autoConnect = false
    
    var body: some View {
        Form {
            Section(header: Text("本地设置")) {
                TextField("本地端口", text: $localPort)
                    .keyboardType(.numberPad)
                
                Toggle("自动连接", isOn: $autoConnect)
            }
            
            Section(header: Text("说明")) {
                Text("本地端口用于其他应用连接到GOST代理")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("代理设置")
    }
}
