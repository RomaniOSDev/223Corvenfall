import SwiftUI

struct AppPrimaryButton: View {
    let title: String
    var icon: String?
    var style: Style = .filled
    var highlighted: Bool = false
    let action: () -> Void

    enum Style {
        case filled
        case outlined
    }

    @State private var isPressed = false

    var body: some View {
        Button {
            FeedbackHelper.lightTap()
            action()
        } label: {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .font(.headline)
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background { buttonBackground }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                if highlighted {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color("AppAccent"), lineWidth: 2.5)
                } else if style == .outlined {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color("AppPrimary").opacity(0.45), lineWidth: 1)
                }
            }
            .compositingGroup()
            .shadow(
                color: style == .filled
                    ? Color("AppBackground").opacity(0.3)
                    : Color.clear,
                radius: style == .filled ? 6 : 0,
                y: style == .filled ? 3 : 0
            )
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = true } }
                .onEnded { _ in withAnimation(.easeInOut(duration: 0.15)) { isPressed = false } }
        )
    }

    @ViewBuilder
    private var buttonBackground: some View {
        if style == .filled {
            ZStack {
                AppGradients.primaryButton
                AppGradients.topHighlight
            }
        } else {
            AppGradients.insetSurface
        }
    }

    private var foregroundColor: Color {
        style == .filled ? Color("AppBackground") : Color("AppPrimary")
    }
}
