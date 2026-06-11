import SwiftUI

struct UVHistoryPillCell: View {
    let dayInitial: String
    let uvLevel: Int
    var isToday: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Text(dayInitial)
                .font(.caption2.bold())
                .foregroundStyle(Color("AppTextSecondary"))

            ZStack {
                Circle()
                    .stroke(Color("AppAccent").opacity(0.25), lineWidth: 3)
                    .frame(width: 48, height: 48)

                Circle()
                    .trim(from: 0, to: CGFloat(uvLevel) / 11.0)
                    .stroke(AppGradients.selectedSegment, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-90))

                Text("\(uvLevel)")
                    .font(.headline.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
            }

            if isToday {
                Text("Today")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color("AppBackground"))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(AppGradients.selectedSegment))
            }
        }
        .frame(width: 64)
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .appInset(cornerRadius: 16)
        .overlay {
            if isToday {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color("AppAccent").opacity(0.45), lineWidth: 1)
            }
        }
    }
}
