import SwiftUI

struct SafeWindowCard: View {
    let lines: [String]

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                AppSectionHeader(
                    icon: "clock.badge.checkmark.fill",
                    title: "Today's Safe Windows",
                    subtitle: "Plan outdoor time around peak UV"
                )

                if lines.isEmpty {
                    Text("UV data unavailable for today.")
                        .font(.subheadline)
                        .foregroundStyle(Color("AppTextSecondary"))
                } else {
                    VStack(spacing: 8) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { index, line in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color("AppPrimary").opacity(0.2))
                                        .frame(width: 28, height: 28)
                                    Text("\(index + 1)")
                                        .font(.caption2.bold())
                                        .foregroundStyle(Color("AppPrimary"))
                                }
                                Text(line)
                                    .font(.subheadline)
                                    .foregroundStyle(Color("AppTextPrimary"))
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.8)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("AppBackground").opacity(0.28))
                            )
                        }
                    }
                }
            }
        }
    }
}
