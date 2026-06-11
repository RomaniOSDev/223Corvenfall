import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var markdownText = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color("AppBackground").ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    AppCard {
                        if let attributed = try? AttributedString(markdown: markdownText) {
                            Text(attributed)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .tint(Color("AppPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            Text(markdownText)
                                .foregroundStyle(Color("AppTextPrimary"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(16)
                }
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color("AppSurface"), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        FeedbackHelper.lightTap()
                        dismiss()
                    }
                    .foregroundStyle(Color("AppPrimary"))
                }
            }
            .onAppear {
                loadPolicy()
            }
        }
    }

    private func loadPolicy() {
        guard let url = Bundle.main.url(forResource: "privacy_policy", withExtension: "md"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            markdownText = "# Privacy Policy\nContent unavailable."
            return
        }
        markdownText = text
    }
}
