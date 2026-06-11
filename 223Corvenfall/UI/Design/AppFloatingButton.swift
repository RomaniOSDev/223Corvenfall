import SwiftUI

struct AppFloatingButton: View {
    let icon: String
    var title: String?
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackHelper.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: title == nil ? 22 : 16, weight: .bold))
                if let title {
                    Text(title)
                        .font(.subheadline.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .foregroundStyle(Color("AppBackground"))
            .padding(.horizontal, title == nil ? 0 : 16)
            .padding(.vertical, title == nil ? 0 : 12)
            .frame(width: title == nil ? 56 : nil, height: 56)
            .background {
                ZStack {
                    Capsule(style: .continuous).fill(AppGradients.primaryButton)
                    Capsule(style: .continuous).fill(AppGradients.topHighlight)
                }
            }
            .clipShape(Capsule(style: .continuous))
            .compositingGroup()
            .shadow(
                color: Color("AppBackground").opacity(0.38),
                radius: 10,
                y: 5
            )
            .scaleEffect(isPressed ? 0.94 : 1)
        }
        .buttonStyle(.plain)
        .frame(minWidth: 44, minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
