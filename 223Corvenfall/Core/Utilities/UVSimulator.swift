import Foundation

enum UVSimulator {
    static func currentUVLevel(for date: Date = Date()) -> Int {
        uvLevel(for: date)
    }

    static func uvLevel(for date: Date) -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let month = calendar.component(.month, from: date)
        let seasonalFactor = sin(Double(month - 1) / 12.0 * .pi) * 0.3 + 0.7
        let fractionalHour = Double(hour) + Double(minute) / 60.0
        let hourFactor = max(0, sin((fractionalHour - 6) / 12.0 * .pi))
        let value = hourFactor * seasonalFactor * 11.0
        return min(11, max(0, Int(value.rounded())))
    }

    static func hourlyLevels(for date: Date = Date()) -> [(hour: Int, level: Int)] {
        let calendar = Calendar.current
        let dayComponents = calendar.dateComponents([.year, .month, .day], from: date)
        return (0..<24).compactMap { hour in
            var components = dayComponents
            components.hour = hour
            components.minute = 0
            guard let hourDate = calendar.date(from: components) else { return nil }
            return (hour, uvLevel(for: hourDate))
        }
    }

    static func safeWindowLines(for date: Date = Date()) -> [String] {
        let levels = hourlyLevels(for: date)
        guard !levels.isEmpty else { return [] }

        var lines: [String] = []

        if let firstModerate = levels.first(where: { $0.level >= 3 }) {
            lines.append("Low until \(formatHour(firstModerate.hour))")
        } else {
            lines.append("Low all day")
        }

        let peakLevel = levels.map(\.level).max() ?? 0
        if peakLevel >= 6 {
            let peakHours = levels.filter { $0.level >= max(6, peakLevel - 1) }.map(\.hour)
            if let range = contiguousRange(from: peakHours) {
                lines.append("Peak \(formatHour(range.lowerBound)) – \(formatHour(range.upperBound + 1))")
            }
        }

        let highHours = levels.filter { $0.level >= 6 }.map(\.hour)
        if let shadeRange = contiguousRange(from: highHours), peakLevel >= 6 {
            lines.append("Seek shade \(formatHour(shadeRange.lowerBound)) – \(formatHour(shadeRange.upperBound + 1))")
        }

        return lines
    }

    private static func contiguousRange(from hours: [Int]) -> ClosedRange<Int>? {
        guard let first = hours.min(), let last = hours.max() else { return nil }
        return first...last
    }

    static func formatHour(_ hour: Int) -> String {
        let calendar = Calendar.current
        var components = DateComponents()
        components.hour = hour % 24
        components.minute = 0
        let date = calendar.date(from: components) ?? Date()
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h a"
        return formatter.string(from: date)
    }

    static func uvLabel(for level: Int) -> String {
        switch level {
        case 0...2: return "Low"
        case 3...5: return "Moderate"
        case 6...7: return "High"
        case 8...10: return "Very High"
        default: return "Extreme"
        }
    }

    static func dayInitial(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }

    static func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
