import SwiftUI

struct CustomSegmentedControl<Option: Hashable>: View {
    let options: [Option]
    let title: (Option) -> String
    @Binding var selection: Option

    var body: some View {
        HStack(spacing: 6) {
            ForEach(options, id: \.self) { option in
                let isSelected = selection == option
                Button {
                    FeedbackHelper.lightTap()
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selection = option
                    }
                } label: {
                    Text(title(option))
                        .font(.caption.bold())
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundStyle(isSelected ? Color("AppBackground") : Color("AppTextSecondary"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(AppGradients.selectedSegment)
                            } else {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color("AppBackground").opacity(0.28))
                            }
                        }
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
            }
        }
        .padding(4)
        .appElevated(.inset, cornerRadius: 14)
    }
}
