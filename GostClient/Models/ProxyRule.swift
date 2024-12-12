import Foundation

struct ProxyRule: Codable, Identifiable {
    var id = UUID()
    var pattern: String
    var isEnabled: Bool
    var action: RuleAction
    var description: String
    
    enum RuleAction: String, Codable {
        case proxy
        case direct
        case reject
    }
}

class ProxyRuleManager: ObservableObject {
    @Published var rules: [ProxyRule] = []
    
    private let rulesKey = "ProxyRules"
    
    init() {
        loadRules()
    }
    
    func addRule(_ rule: ProxyRule) {
        rules.append(rule)
        saveRules()
    }
    
    func removeRule(at index: Int) {
        rules.remove(at: index)
        saveRules()
    }
    
    func updateRule(_ rule: ProxyRule) {
        if let index = rules.firstIndex(where: { $0.id == rule.id }) {
            rules[index] = rule
            saveRules()
        }
    }
    
    private func loadRules() {
        if let data = UserDefaults.standard.data(forKey: rulesKey),
           let savedRules = try? JSONDecoder().decode([ProxyRule].self, from: data) {
            rules = savedRules
        }
    }
    
    private func saveRules() {
        if let data = try? JSONEncoder().encode(rules) {
            UserDefaults.standard.set(data, forKey: rulesKey)
        }
    }
}
