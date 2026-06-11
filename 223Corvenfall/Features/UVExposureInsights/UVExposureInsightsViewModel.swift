import Combine
import Foundation
import SwiftUI

@MainActor
final class UVExposureInsightsViewModel: ObservableObject {
    @Published var showAddSheet = false
    @Published var editingRecord: UVRecord?
    @Published var showCheckmark = false

    private weak var store: AppStorageStore?

    var filteredRecords: [UVRecord] {
        guard let store else { return [] }
        let calendar = Calendar.current
        let now = Date()

        switch store.selectedView {
        case "daily":
            let start = calendar.startOfDay(for: now)
            return store.uvRecords.filter { calendar.isDate($0.date, inSameDayAs: start) }
                .sorted { $0.date > $1.date }
        case "monthly":
            guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else {
                return store.uvRecords.sorted { $0.date > $1.date }
            }
            return store.uvRecords.filter { $0.date >= monthStart }
                .sorted { $0.date > $1.date }
        default:
            guard let weekStart = calendar.date(byAdding: .day, value: -7, to: now) else {
                return store.uvRecords.sorted { $0.date > $1.date }
            }
            return store.uvRecords.filter { $0.date >= weekStart }
                .sorted { $0.date > $1.date }
        }
    }

    var chartData: [(date: Date, value: Float)] {
        filteredRecords.map { ($0.date, $0.maxIndex) }.sorted { $0.date < $1.date }
    }

    func configure(store: AppStorageStore) {
        self.store = store
    }

    func setView(_ view: String) {
        store?.selectedView = view
        FeedbackHelper.lightTap()
    }

    func openAdd() {
        FeedbackHelper.lightTap()
        editingRecord = nil
        showAddSheet = true
    }

    func openEdit(_ record: UVRecord) {
        FeedbackHelper.lightTap()
        editingRecord = record
        showAddSheet = true
    }

    func delete(_ record: UVRecord) {
        store?.uvRecords.removeAll { $0.id == record.id }
        FeedbackHelper.lightTap()
        store?.registerMeaningfulAction()
    }

    func saveRecord(date: Date, maxIndex: Float, duration: Int, existingID: UUID?) {
        guard let store else { return }

        if let existingID,
           let index = store.uvRecords.firstIndex(where: { $0.id == existingID }) {
            store.uvRecords[index] = UVRecord(
                id: existingID,
                date: date,
                maxIndex: maxIndex,
                exposureDuration: duration
            )
        } else {
            store.uvRecords.append(UVRecord(date: date, maxIndex: maxIndex, exposureDuration: duration))
            store.incrementItemCreated()
        }

        store.registerMeaningfulAction()
        FeedbackHelper.confirmAdd()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCheckmark = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.showCheckmark = false
        }
    }
}
