import Foundation

enum UVProtectionAdvice {
    static func tips(for level: Int) -> [ProtectionTip] {
        switch level {
        case 0...2:
            return [
                ProtectionTip(id: "spf_light", iconName: "drop.fill", text: "SPF 15+ on bright days"),
                ProtectionTip(id: "glasses", iconName: "eyeglasses", text: "Sunglasses recommended"),
                ProtectionTip(id: "shade_ok", iconName: "leaf.fill", text: "Shade optional for short outings")
            ]
        case 3...5:
            return [
                ProtectionTip(id: "spf30", iconName: "drop.fill", text: "Apply SPF 30+ every 2 hours"),
                ProtectionTip(id: "hat", iconName: "hat.widebrim.fill", text: "Wear a wide-brim hat outdoors"),
                ProtectionTip(id: "shade_mid", iconName: "cloud.sun.fill", text: "Seek shade during midday hours")
            ]
        case 6...7:
            return [
                ProtectionTip(id: "spf50", iconName: "drop.fill", text: "Use SPF 50+ and reapply often"),
                ProtectionTip(id: "hat_req", iconName: "hat.widebrim.fill", text: "Hat and UV-blocking sunglasses required"),
                ProtectionTip(id: "shade_10_4", iconName: "sun.min.fill", text: "Limit sun between 10 AM and 4 PM")
            ]
        default:
            return [
                ProtectionTip(id: "spf50_max", iconName: "drop.fill", text: "SPF 50+ — reapply every 90 minutes"),
                ProtectionTip(id: "full_cover", iconName: "tshirt.fill", text: "Long sleeves and full coverage"),
                ProtectionTip(id: "avoid_peak", iconName: "exclamationmark.shield.fill", text: "Avoid peak hours — stay in shade")
            ]
        }
    }

    static func summary(for level: Int) -> String {
        tips(for: level).map(\.text).joined(separator: " ")
    }
}
