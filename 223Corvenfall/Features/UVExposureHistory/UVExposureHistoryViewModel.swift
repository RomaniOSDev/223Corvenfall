import Combine
import Foundation
import SwiftUI

@MainActor
final class UVExposureHistoryViewModel: ObservableObject {
    @Published var showLogSettings = false
    @Published var showSuccessPulse = false

    private weak var store: AppStorageStore?

    struct DayEntry: Identifiable, Hashable {
        let id: String
        let date: Date
        let maxUV: Float
    }

    var sortedEntries: [DayEntry] {
        guard let store else { return [] }
        return store.uvLogs
            .compactMap { key, value -> DayEntry? in
                guard let date = dateFromKey(key) else { return nil }
                return DayEntry(id: key, date: date, maxUV: value)
            }
            .sorted { $0.date > $1.date }
    }

    var chartEntries: [DayEntry] {
        let calendar = Calendar.current
        guard let monthAgo = calendar.date(byAdding: .day, value: -30, to: Date()) else {
            return sortedEntries
        }
        return sortedEntries.filter { $0.date >= monthAgo }.sorted { $0.date < $1.date }
    }

    func configure(store: AppStorageStore) {
        self.store = store
    }

    func openLogSettings() {
        FeedbackHelper.lightTap()
        showLogSettings = true
    }

    func onLoggingSaved() {
        withAnimation(.easeInOut(duration: 0.4)) {
            showSuccessPulse = true
        }
        FeedbackHelper.confirmLight()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.showSuccessPulse = false
        }
    }

    private func dateFromKey(_ key: String) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: key)
    }
}
