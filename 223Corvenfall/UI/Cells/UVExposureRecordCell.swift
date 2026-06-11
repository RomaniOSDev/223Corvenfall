import SwiftUI

struct UVExposureRecordCell: View {
    let date: Date
    let durationMinutes: Int
    let maxIndex: Float

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 2) {
                Text(dayNumber)
                    .font(.title3.bold())
                    .foregroundStyle(Color("AppTextPrimary"))
                Text(monthAbbrev)
                    .font(.caption2.bold())
                    .foregroundStyle(Color("AppTextSecondary"))
            }
            .frame(width: 44)

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color("AppAccent").opacity(0.05), Color("AppAccent").opacity(0.35)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 1, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color("AppTextPrimary"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.caption2)
                    Text("\(durationMinutes) min exposure")
                        .font(.caption)
                }
                .foregroundStyle(Color("AppTextSecondary"))
            }

            Spacer(minLength: 4)

            VStack(alignment: .trailing, spacing: 4) {
                UVLevelBadge(level: Int(maxIndex.rounded()))
                Text(UVSimulator.uvLabel(for: Int(maxIndex.rounded())))
                    .font(.caption2)
                    .foregroundStyle(Color("AppTextSecondary"))
            }
        }
        .padding(14)
        .frame(minHeight: 76)
        .appInset(cornerRadius: 16)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    private var monthAbbrev: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).uppercased()
    }
}
