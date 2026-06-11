import SwiftUI

struct AddUVRecordSheet: View {
    @Environment(\.dismiss) private var dismiss

    let existingRecord: UVRecord?
    var onSave: (Date, Float, Int, UUID?) -> Void

    @State private var date: Date
    @State private var maxIndex: Double
    @State private var duration: Int
    @State private var errorMessage: String?
    @State private var shakeTrigger = 0

    init(existingRecord: UVRecord?, onSave: @escaping (Date, Float, Int, UUID?) -> Void) {
        self.existingRecord = existingRecord
        self.onSave = onSave
        _date = State(initialValue: existingRecord?.date ?? Date())
        _maxIndex = State(initialValue: Double(existingRecord?.maxIndex ?? 5))
        _duration = State(initialValue: existingRecord?.exposureDuration ?? 30)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        AppCard {
                            VStack(alignment: .leading, spacing: 18) {
                                AppSectionHeader(
                                    icon: "square.and.pencil",
                                    title: existingRecord == nil ? "New Record" : "Edit Record",
                                    subtitle: "Log UV exposure for a day"
                                )

                                DatePicker("Date", selection: $date, displayedComponents: .date)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .tint(Color("AppPrimary"))
                                    .onChange(of: date) { _ in FeedbackHelper.lightTap() }

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Max UV Index")
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        UVLevelBadge(level: Int(maxIndex.rounded()))
                                    }
                                    Slider(value: $maxIndex, in: 0...11, step: 0.5)
                                        .tint(Color("AppAccent"))
                                        .onChange(of: maxIndex) { _ in FeedbackHelper.tick() }
                                }
                                .shake(trigger: shakeTrigger)

                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Exposure Duration")
                                            .foregroundStyle(Color("AppTextPrimary"))
                                        Spacer()
                                        Text("\(duration) min")
                                            .font(.subheadline.bold())
                                            .foregroundStyle(Color("AppAccent"))
                                    }
                                    Slider(
                                        value: Binding(
                                            get: { Double(duration) },
                                            set: { duration = Int($0) }
                                        ),
                                        in: 5...480,
                                        step: 5
                                    )
                                    .tint(Color("AppPrimary"))
                                    .onChange(of: duration) { _ in FeedbackHelper.tick() }
                                }

                                if let errorMessage {
                                    Text(errorMessage)
                                        .font(.caption)
                                        .foregroundStyle(Color("AppAccent"))
                                }
                            }
                        }

                        AppPrimaryButton(title: "Save Entry", icon: "checkmark") {
                            save()
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle(existingRecord == nil ? "Add Entry" : "Edit Entry")
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

    private func save() {
        guard maxIndex >= 0, maxIndex <= 11 else {
            errorMessage = "UV index must be between 0 and 11."
            shakeTrigger += 1
            FeedbackHelper.warning()
            return
        }
        guard duration > 0 else {
            errorMessage = "Duration must be greater than zero."
            shakeTrigger += 1
            FeedbackHelper.warning()
            return
        }

        errorMessage = nil
        FeedbackHelper.mediumTap()
        onSave(date, Float(maxIndex), duration, existingRecord?.id)
        dismiss()
    }
}
