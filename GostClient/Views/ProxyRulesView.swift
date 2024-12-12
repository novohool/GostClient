import SwiftUI

struct ProxyRulesView: View {
    @StateObject private var ruleManager = ProxyRuleManager()
    @State private var showingAddRule = false
    @State private var editingRule: ProxyRule?
    
    var body: some View {
        List {
            ForEach(ruleManager.rules) { rule in
                RuleRow(rule: rule) {
                    editingRule = rule
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { index in
                    ruleManager.removeRule(at: index)
                }
            }
        }
        .navigationTitle("代理规则")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddRule = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddRule) {
            NavigationView {
                RuleEditView(rule: ProxyRule(pattern: "", isEnabled: true, action: .proxy, description: "")) { rule in
                    ruleManager.addRule(rule)
                }
            }
        }
        .sheet(item: $editingRule) { rule in
            NavigationView {
                RuleEditView(rule: rule) { updatedRule in
                    ruleManager.updateRule(updatedRule)
                }
            }
        }
    }
}

struct RuleRow: View {
    let rule: ProxyRule
    let onEdit: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(rule.pattern)
                    .font(.headline)
                Text(rule.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(rule.action.rawValue)
                .font(.caption)
                .padding(4)
                .background(actionColor)
                .foregroundColor(.white)
                .cornerRadius(4)
        }
        .opacity(rule.isEnabled ? 1.0 : 0.5)
        .onTapGesture {
            onEdit()
        }
    }
    
    private var actionColor: Color {
        switch rule.action {
        case .proxy:
            return .blue
        case .direct:
            return .green
        case .reject:
            return .red
        }
    }
}

struct RuleEditView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var pattern: String
    @State private var isEnabled: Bool
    @State private var action: ProxyRule.RuleAction
    @State private var description: String
    
    let rule: ProxyRule
    let onSave: (ProxyRule) -> Void
    
    init(rule: ProxyRule, onSave: @escaping (ProxyRule) -> Void) {
        self.rule = rule
        self.onSave = onSave
        _pattern = State(initialValue: rule.pattern)
        _isEnabled = State(initialValue: rule.isEnabled)
        _action = State(initialValue: rule.action)
        _description = State(initialValue: rule.description)
    }
    
    var body: some View {
        Form {
            Section(header: Text("规则设置")) {
                TextField("匹配模式", text: $pattern)
                Toggle("启用", isOn: $isEnabled)
                Picker("动作", selection: $action) {
                    Text("代理").tag(ProxyRule.RuleAction.proxy)
                    Text("直连").tag(ProxyRule.RuleAction.direct)
                    Text("拒绝").tag(ProxyRule.RuleAction.reject)
                }
            }
            
            Section(header: Text("描述")) {
                TextField("规则描述", text: $description)
            }
        }
        .navigationTitle(rule.pattern.isEmpty ? "添加规则" : "编辑规则")
        .navigationBarItems(
            leading: Button("取消") {
                presentationMode.wrappedValue.dismiss()
            },
            trailing: Button("保存") {
                let updatedRule = ProxyRule(
                    id: rule.id,
                    pattern: pattern,
                    isEnabled: isEnabled,
                    action: action,
                    description: description
                )
                onSave(updatedRule)
                presentationMode.wrappedValue.dismiss()
            }
        )
    }
}
