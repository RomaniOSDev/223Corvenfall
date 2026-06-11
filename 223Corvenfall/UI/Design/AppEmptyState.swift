import SwiftUI

struct AppEmptyState: View {
    let icon: String
    let title: String
    var message: String?
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppGradients.glow())
                    .frame(width: 88, height: 88)
                Circle()
                    .fill(AppGradients.selectedSegment)
                    .frame(width: 64, height: 64)
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundStyle(Color("AppBackground"))
            }

            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)

            if let message {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(Color("AppTextSecondary"))
                    .multilineTextAlignment(.center)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.caption.bold())
                        .foregroundStyle(Color("AppBackground"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Capsule().fill(AppGradients.primaryButton))
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
    }
}
