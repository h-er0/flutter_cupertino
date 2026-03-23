import Foundation

struct AdaptiveMenuItemData: Identifiable {
    let id: Int
    let label: String
    let icon: String?
    let isDestructive: Bool
    let isEnabled: Bool
    let type: Int  // 0: action, 1: submenu, 2: section
    let children: [AdaptiveMenuItemData]?
}

extension AdaptiveMenuItemData {
    static func from(map: [String: Any]) -> AdaptiveMenuItemData {
        let id = map["id"] as? Int ?? -1
        let label = map["label"] as? String ?? ""
        let icon = map["icon"] as? String
        let isDestructive = map["isDestructive"] as? Bool ?? false
        let isEnabled = map["isEnabled"] as? Bool ?? true
        let type = map["type"] as? Int ?? 0

        var children: [AdaptiveMenuItemData]? = nil
        if let childrenList = map["children"] as? [Any] {
            // Safer mapping from Any
            children = childrenList.compactMap { $0 as? [String: Any] }.map {
                AdaptiveMenuItemData.from(map: $0)
            }
        }

        return AdaptiveMenuItemData(
            id: id,
            label: label,
            icon: icon,
            isDestructive: isDestructive,
            isEnabled: isEnabled,
            type: type,
            children: children
        )
    }
}
