import SwiftUI

struct ProtectionTipCell: View {
    let tip: ProtectionTip

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(AppGradients.selectedSegment)
                    .frame(width: 36, height: 36)
                Image(systemName: tip.iconName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color("AppBackground"))
            }

            Text(tip.text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color("AppTextSecondary"))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(minHeight: 44, alignment: .center)
    }
}
