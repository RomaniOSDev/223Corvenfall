import SwiftUI

struct LogSettingsSheet: View {
    @EnvironmentObject private var store: AppStorageStore
    @Environment(\.dismiss) private var dismiss
    var onSaved: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        AppCard {
                            VStack(alignment: .leading, spacing: 16) {
                                AppSectionHeader(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Exposure Logging",
                                    subtitle: "Auto-record daily max UV"
                                )

                                Toggle("Enable Exposure Logging", isOn: $store.loggingEnabled)
                                    .tint(Color("AppPrimary"))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .onChange(of: store.loggingEnabled) { enabled in
                                        FeedbackHelper.lightTap()
                                        if enabled {
                                            let level = UVSimulator.currentUVLevel()
                                            let key = UVSimulator.dateKey(for: Date())
                                            let current = store.uvLogs[key] ?? 0
                                            store.uvLogs[key] = max(current, Float(level))
                                            store.incrementItemCreated()
                                        }
                                    }

                                Text("When enabled, daily maximum UV levels are recorded automatically.")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }

                        AppPrimaryButton(title: "Save Settings", icon: "checkmark") {
                            store.registerMeaningfulAction()
                            onSaved()
                            dismiss()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Log Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        FeedbackHelper.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppTextSecondary"))
                }
            }
        }
    }
}
