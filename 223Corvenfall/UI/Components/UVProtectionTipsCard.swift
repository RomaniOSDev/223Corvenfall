import SwiftUI

struct UVProtectionTipsCard: View {
    let uvLevel: Int
    var embedded: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AppSectionHeader(
                icon: "shield.lefthalf.filled",
                title: "Protection Tips",
                subtitle: "Based on current UV level"
            )

            ForEach(UVProtectionAdvice.tips(for: uvLevel)) { tip in
                ProtectionTipCell(tip: tip)
            }
        }
        .padding(embedded ? 14 : 0)
        .background {
            if embedded {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppGradients.insetSurface)
                    .overlay {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color("AppAccent").opacity(0.1), lineWidth: 1)
                    }
            }
        }
    }
}
