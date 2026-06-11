import SwiftUI

struct AlertSettingsSheet: View {
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
                                    icon: "bell.badge.fill",
                                    title: "Alert Configuration",
                                    subtitle: "In-app UV threshold alerts"
                                )

                                Toggle("Enable UV Alerts", isOn: $store.isAlertEnabled)
                                    .tint(Color("AppPrimary"))
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .onChange(of: store.isAlertEnabled) { _ in
                                        FeedbackHelper.lightTap()
                                    }

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Threshold")
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        UVLevelBadge(level: store.alertThreshold)
                                    }

                                    Stepper(value: $store.alertThreshold, in: 1...11) {
                                        EmptyView()
                                    }
                                    .onChange(of: store.alertThreshold) { _ in
                                        FeedbackHelper.tick()
                                    }
                                }

                                Text("You will be notified in-app when UV reaches this level.")
                                    .font(.caption)
                                    .foregroundStyle(Color("AppTextSecondary"))
                            }
                        }

                        AppPrimaryButton(title: "Save Alert", icon: "checkmark") {
                            store.registerMeaningfulAction()
                            onSaved()
                            dismiss()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Set Alert")
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
