import SwiftUI

struct SuccessCheckmarkOverlay: View {
    @Binding var isVisible: Bool

    var body: some View {
        ZStack {
            if isVisible {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color("AppAccent"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isVisible)
        .allowsHitTesting(false)
    }

    static func trigger(_ binding: Binding<Bool>) {
        binding.wrappedValue = true
        FeedbackHelper.success()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            binding.wrappedValue = false
        }
    }
}
