import Combine
import Foundation

final class AppStorageStore: ObservableObject {
    static let shared = AppStorageStore()

    private enum Keys {
        static let hasSeenOnboarding = "hasSeenOnboarding"
        static let totalSessionsCompleted = "totalSessionsCompleted"
        static let totalMinutesUsed = "totalMinutesUsed"
        static let streakDays = "streakDays"
        static let lastActivityDate = "lastActivityDate"
        static let achievementsUnlocked = "achievementsUnlocked"
        static let itemsCreated = "itemsCreated"
        static let uvIndexHistory = "uvIndexHistory"
        static let alertThreshold = "alertThreshold"
        static let isAlertEnabled = "isAlertEnabled"
        static let uvLogs = "uvLogs"
        static let loggingEnabled = "loggingEnabled"
        static let uvRecords = "uvRecords"
        static let selectedView = "selectedView"
        static let highUVDaysAlerted = "highUVDaysAlerted"
        static let spfTimerEndsAt = "spfTimerEndsAt"
        static let spfTimerDurationMinutes = "spfTimerDurationMinutes"
        static let spfReminderPending = "spfReminderPending"
        static let dailyExposureGoalMinutes = "dailyExposureGoalMinutes"
    }

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published var hasSeenOnboarding: Bool {
        didSet { defaults.set(hasSeenOnboarding, forKey: Keys.hasSeenOnboarding) }
    }

    @Published var totalSessionsCompleted: Int {
        didSet { defaults.set(totalSessionsCompleted, forKey: Keys.totalSessionsCompleted) }
    }

    @Published var totalMinutesUsed: Int {
        didSet { defaults.set(totalMinutesUsed, forKey: Keys.totalMinutesUsed) }
    }

    @Published var streakDays: Int {
        didSet { defaults.set(streakDays, forKey: Keys.streakDays) }
    }

    @Published var lastActivityDate: Date? {
        didSet {
            if let date = lastActivityDate {
                defaults.set(date.timeIntervalSince1970, forKey: Keys.lastActivityDate)
            } else {
                defaults.removeObject(forKey: Keys.lastActivityDate)
            }
        }
    }

    @Published var achievementsUnlocked: [String: Date] {
        didSet { saveAchievements() }
    }

    @Published var itemsCreated: Int {
        didSet { defaults.set(itemsCreated, forKey: Keys.itemsCreated) }
    }

    @Published var uvIndexHistory: [UVHistoryEntry] {
        didSet { saveHistory() }
    }

    @Published var alertThreshold: Int {
        didSet { defaults.set(alertThreshold, forKey: Keys.alertThreshold) }
    }

    @Published var isAlertEnabled: Bool {
        didSet { defaults.set(isAlertEnabled, forKey: Keys.isAlertEnabled) }
    }

    @Published var uvLogs: [String: Float] {
        didSet { saveUVLogs() }
    }

    @Published var loggingEnabled: Bool {
        didSet { defaults.set(loggingEnabled, forKey: Keys.loggingEnabled) }
    }

    @Published var uvRecords: [UVRecord] {
        didSet { saveUVRecords() }
    }

    @Published var selectedView: String {
        didSet { defaults.set(selectedView, forKey: Keys.selectedView) }
    }

    @Published var highUVDaysAlerted: Int {
        didSet { defaults.set(highUVDaysAlerted, forKey: Keys.highUVDaysAlerted) }
    }

    @Published var spfTimerEndsAt: Date? {
        didSet {
            if let date = spfTimerEndsAt {
                defaults.set(date.timeIntervalSince1970, forKey: Keys.spfTimerEndsAt)
            } else {
                defaults.removeObject(forKey: Keys.spfTimerEndsAt)
            }
        }
    }

    @Published var spfTimerDurationMinutes: Int {
        didSet { defaults.set(spfTimerDurationMinutes, forKey: Keys.spfTimerDurationMinutes) }
    }

    @Published var spfReminderPending: Bool {
        didSet { defaults.set(spfReminderPending, forKey: Keys.spfReminderPending) }
    }

    @Published var dailyExposureGoalMinutes: Int {
        didSet { defaults.set(dailyExposureGoalMinutes, forKey: Keys.dailyExposureGoalMinutes) }
    }

    var todayExposureMinutes: Int {
        let calendar = Calendar.current
        return uvRecords
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.exposureDuration }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        if defaults.object(forKey: Keys.lastActivityDate) != nil {
            lastActivityDate = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastActivityDate))
        } else {
            lastActivityDate = nil
        }
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        alertThreshold = defaults.object(forKey: Keys.alertThreshold) as? Int ?? 6
        isAlertEnabled = defaults.bool(forKey: Keys.isAlertEnabled)
        loggingEnabled = defaults.bool(forKey: Keys.loggingEnabled)
        selectedView = defaults.string(forKey: Keys.selectedView) ?? "weekly"
        highUVDaysAlerted = defaults.integer(forKey: Keys.highUVDaysAlerted)
        spfTimerDurationMinutes = defaults.object(forKey: Keys.spfTimerDurationMinutes) as? Int ?? 120
        spfReminderPending = defaults.bool(forKey: Keys.spfReminderPending)
        dailyExposureGoalMinutes = defaults.object(forKey: Keys.dailyExposureGoalMinutes) as? Int ?? 60
        if defaults.object(forKey: Keys.spfTimerEndsAt) != nil {
            spfTimerEndsAt = Date(timeIntervalSince1970: defaults.double(forKey: Keys.spfTimerEndsAt))
        } else {
            spfTimerEndsAt = nil
        }

        if let data = defaults.data(forKey: Keys.achievementsUnlocked),
           let decoded = try? decoder.decode([String: Date].self, from: data) {
            achievementsUnlocked = decoded
        } else {
            achievementsUnlocked = [:]
        }

        if let data = defaults.data(forKey: Keys.uvIndexHistory),
           let decoded = try? decoder.decode([UVHistoryEntry].self, from: data) {
            uvIndexHistory = decoded
        } else {
            uvIndexHistory = []
        }

        if let data = defaults.data(forKey: Keys.uvLogs),
           let decoded = try? decoder.decode([String: Float].self, from: data) {
            uvLogs = decoded
        } else {
            uvLogs = [:]
        }

        if let data = defaults.data(forKey: Keys.uvRecords),
           let decoded = try? decoder.decode([UVRecord].self, from: data) {
            uvRecords = decoded
        } else {
            uvRecords = []
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataReset),
            name: .dataReset,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handleDataReset() {
        reloadFromDefaults()
    }

    func reloadFromDefaults() {
        hasSeenOnboarding = defaults.bool(forKey: Keys.hasSeenOnboarding)
        totalSessionsCompleted = defaults.integer(forKey: Keys.totalSessionsCompleted)
        totalMinutesUsed = defaults.integer(forKey: Keys.totalMinutesUsed)
        streakDays = defaults.integer(forKey: Keys.streakDays)
        if defaults.object(forKey: Keys.lastActivityDate) != nil {
            lastActivityDate = Date(timeIntervalSince1970: defaults.double(forKey: Keys.lastActivityDate))
        } else {
            lastActivityDate = nil
        }
        itemsCreated = defaults.integer(forKey: Keys.itemsCreated)
        alertThreshold = defaults.object(forKey: Keys.alertThreshold) as? Int ?? 6
        isAlertEnabled = defaults.bool(forKey: Keys.isAlertEnabled)
        loggingEnabled = defaults.bool(forKey: Keys.loggingEnabled)
        selectedView = defaults.string(forKey: Keys.selectedView) ?? "weekly"
        highUVDaysAlerted = defaults.integer(forKey: Keys.highUVDaysAlerted)
        spfTimerDurationMinutes = defaults.object(forKey: Keys.spfTimerDurationMinutes) as? Int ?? 120
        spfReminderPending = defaults.bool(forKey: Keys.spfReminderPending)
        dailyExposureGoalMinutes = defaults.object(forKey: Keys.dailyExposureGoalMinutes) as? Int ?? 60
        if defaults.object(forKey: Keys.spfTimerEndsAt) != nil {
            spfTimerEndsAt = Date(timeIntervalSince1970: defaults.double(forKey: Keys.spfTimerEndsAt))
        } else {
            spfTimerEndsAt = nil
        }

        if let data = defaults.data(forKey: Keys.achievementsUnlocked),
           let decoded = try? decoder.decode([String: Date].self, from: data) {
            achievementsUnlocked = decoded
        } else {
            achievementsUnlocked = [:]
        }

        if let data = defaults.data(forKey: Keys.uvIndexHistory),
           let decoded = try? decoder.decode([UVHistoryEntry].self, from: data) {
            uvIndexHistory = decoded
        } else {
            uvIndexHistory = []
        }

        if let data = defaults.data(forKey: Keys.uvLogs),
           let decoded = try? decoder.decode([String: Float].self, from: data) {
            uvLogs = decoded
        } else {
            uvLogs = [:]
        }

        if let data = defaults.data(forKey: Keys.uvRecords),
           let decoded = try? decoder.decode([UVRecord].self, from: data) {
            uvRecords = decoded
        } else {
            uvRecords = []
        }
    }

    func resetAllData() {
        let domain = Bundle.main.bundleIdentifier ?? ""
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        reloadFromDefaults()
    }

    func registerMeaningfulAction() {
        updateStreak()
        AchievementManager.shared.evaluate(store: self)
    }

    func incrementItemCreated() {
        itemsCreated += 1
        registerMeaningfulAction()
    }

    func completeSession() {
        totalSessionsCompleted += 1
        registerMeaningfulAction()
    }

    func addUsageMinute() {
        totalMinutesUsed += 1
        AchievementManager.shared.evaluate(store: self)
    }

    func recordUVCheck(level: Int) {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = uvIndexHistory.firstIndex(where: {
            Calendar.current.isDate($0.day, inSameDayAs: today)
        }) {
            var entry = uvIndexHistory[index]
            entry.uvLevel = level
            uvIndexHistory[index] = entry
        } else {
            uvIndexHistory.append(UVHistoryEntry(day: today, uvLevel: level))
        }
        uvIndexHistory.sort { $0.day > $1.day }

        let key = UVSimulator.dateKey(for: today)
        if loggingEnabled {
            let currentMax = uvLogs[key] ?? 0
            uvLogs[key] = max(currentMax, Float(level))
        }

        incrementItemCreated()
        evaluateAlert(for: level)
    }

    func deleteHistoryEntry(_ entry: UVHistoryEntry) {
        uvIndexHistory.removeAll { $0.id == entry.id }
        FeedbackHelper.lightTap()
    }

    func evaluateAlert(for level: Int) {
        guard isAlertEnabled, level >= alertThreshold else { return }
        let key = UVSimulator.dateKey(for: Date())
        let alertedKey = "alerted_\(key)"
        if !defaults.bool(forKey: alertedKey) {
            defaults.set(true, forKey: alertedKey)
            highUVDaysAlerted += 1
        }
    }

    private func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let last = lastActivityDate else {
            streakDays = 1
            lastActivityDate = today
            return
        }

        let lastDay = calendar.startOfDay(for: last)
        if calendar.isDate(lastDay, inSameDayAs: today) {
            return
        }

        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(lastDay, inSameDayAs: yesterday) {
            streakDays += 1
        } else {
            streakDays = 1
        }
        lastActivityDate = today
    }

    private func saveAchievements() {
        if let data = try? encoder.encode(achievementsUnlocked) {
            defaults.set(data, forKey: Keys.achievementsUnlocked)
        }
    }

    private func saveHistory() {
        if let data = try? encoder.encode(uvIndexHistory) {
            defaults.set(data, forKey: Keys.uvIndexHistory)
        }
    }

    private func saveUVLogs() {
        if let data = try? encoder.encode(uvLogs) {
            defaults.set(data, forKey: Keys.uvLogs)
        }
    }

    private func saveUVRecords() {
        if let data = try? encoder.encode(uvRecords) {
            defaults.set(data, forKey: Keys.uvRecords)
        }
    }
}
