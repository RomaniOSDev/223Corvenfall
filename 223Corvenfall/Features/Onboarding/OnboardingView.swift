import SwiftUI

private struct OnboardingPage: Identifiable {
    let id: Int
    let headline: String
    let description: String
    let icon: String
    var imageName: String?
}

struct OnboardingView: View {
    @EnvironmentObject private var store: AppStorageStore
    @State private var currentPage = 0
    @State private var illustrationScale: CGFloat = 0.82
    @State private var illustrationOpacity: Double = 0
    @State private var cardOffset: CGFloat = 24

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            headline: "Stay Sun Safe",
            description: "Get insights on UV levels to protect your skin.",
            icon: "shield.lefthalf.filled",
            imageName: "HomeHero"
        ),
        OnboardingPage(
            id: 1,
            headline: "Monitor UV Index",
            description: "Track real-time UV index to stay informed about sun exposure risks.",
            icon: "gauge.with.needle.fill",
            imageName: "HomeUVWidget"
        ),
        OnboardingPage(
            id: 2,
            headline: "Enable Alerts",
            description: "Receive notifications for high UV days to adjust your plans accordingly.",
            icon: "bell.badge.fill",
            imageName: "HomeProtectionWidget"
        )
    ]

    var body: some View {
        ZStack {
            AppScaffoldBackground()

            VStack(spacing: 0) {
                stepBadge
                    .padding(.top, 12)
                    .padding(.horizontal, 24)

                TabView(selection: $currentPage) {
                    ForEach(pages) { page in
                        pageContent(page)
                            .tag(page.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentPage)

                footerControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, 36)
            }
        }
        .onChange(of: currentPage) { _ in
            animatePageTransition()
        }
        .onAppear {
            animatePageTransition()
        }
    }

    // MARK: - Chrome

    private var stepBadge: some View {
        HStack {
            Spacer()
            Text("Step \(currentPage + 1) of \(pages.count)")
                .font(.caption.bold())
                .foregroundStyle(Color("AppTextSecondary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .appInset(cornerRadius: 10)
        }
    }

    private var footerControls: some View {
        VStack(spacing: 20) {
            pageIndicator

            AppPrimaryButton(
                title: currentPage == pages.count - 1 ? "Get Started" : "Next",
                icon: currentPage == pages.count - 1 ? "checkmark" : "arrow.right"
            ) {
                advance()
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { page in
                Capsule()
                    .fill(
                        currentPage == page.id
                            ? AppGradients.selectedSegment
                            : LinearGradient(
                                colors: [Color("AppTextSecondary").opacity(0.25)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                    .frame(width: currentPage == page.id ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: currentPage)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .appInset(cornerRadius: 14)
    }

    // MARK: - Page

    private func pageContent(_ page: OnboardingPage) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                illustrationStage(for: page)
                    .scaleEffect(illustrationScale)
                    .opacity(illustrationOpacity)

                AppCard(elevation: .card) {
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppGradients.selectedSegment)
                                .frame(width: 52, height: 52)
                            Image(systemName: page.icon)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color("AppBackground"))
                        }
                        .compositingGroup()
                        .shadow(color: Color("AppBackground").opacity(0.2), radius: 5, y: 2)

                        Text(page.headline)
                            .font(.title2.bold())
                            .foregroundStyle(Color("AppTextPrimary"))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.85)

                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color("AppAccent").opacity(0.45),
                                        Color.clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: 64, height: 2)

                        Text(page.description)
                            .font(.body)
                            .foregroundStyle(Color("AppTextSecondary"))
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                }
                .offset(y: cardOffset)
                .opacity(illustrationOpacity)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
    }

    @ViewBuilder
    private func illustrationStage(for page: OnboardingPage) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppGradients.cardSurface)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(AppGradients.topHighlight)
                }

            if let imageName = page.imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
                    .overlay { AppGradients.imageOverlay }
            }

            illustrationOverlay(for: page.id)
        }
        .frame(height: 240)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .appImageFrame(cornerRadius: 28)
        .compositingGroup()
        .shadow(
            color: Color("AppBackground").opacity(AppElevationLevel.prominent.shadowOpacity),
            radius: AppElevationLevel.prominent.shadowRadius,
            y: AppElevationLevel.prominent.shadowYOffset
        )
    }

    @ViewBuilder
    private func illustrationOverlay(for pageId: Int) -> some View {
        switch pageId {
        case 0:
            SunShieldIllustration()
        case 1:
            UVGaugeIllustration()
        default:
            AlertBellIllustration()
        }
    }

    // MARK: - Actions

    private func animatePageTransition() {
        illustrationScale = 0.82
        illustrationOpacity = 0
        cardOffset = 20

        withAnimation(.spring(response: 0.45, dampingFraction: 0.72)) {
            illustrationScale = 1
            illustrationOpacity = 1
            cardOffset = 0
        }
    }

    private func advance() {
        FeedbackHelper.lightTap()
        if currentPage < pages.count - 1 {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        } else {
            FeedbackHelper.success()
            store.hasSeenOnboarding = true
            store.registerMeaningfulAction()
        }
    }
}

// MARK: - Illustrations (SwiftUI overlay accents)

private struct SunShieldIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppGradients.glow(center: .center))
                .frame(width: 160, height: 160)
                .opacity(0.85)

            ForEach(0..<8, id: \.self) { index in
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color("AppAccent"), Color("AppPrimary")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 26)
                    .offset(y: -78)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(0.75)
            }

            Image(systemName: "shield.fill")
                .font(.system(size: 56, weight: .semibold))
                .foregroundStyle(Color("AppTextPrimary"))
                .shadow(color: Color("AppBackground").opacity(0.35), radius: 8, y: 4)
        }
    }
}

private struct UVGaugeIllustration: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppGradients.glow())
                .frame(width: 170, height: 170)

            Circle()
                .stroke(Color("AppBackground").opacity(0.4), lineWidth: 14)
                .frame(width: 140, height: 140)

            Circle()
                .trim(from: 0, to: 0.65)
                .stroke(
                    AppGradients.gaugeRing,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .frame(width: 140, height: 140)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("6")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("AppTextPrimary"))
                Text("Moderate")
                    .font(.caption.bold())
                    .foregroundStyle(Color("AppAccent"))
            }
        }
    }
}

private struct AlertBellIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(AppGradients.insetSurface)
                .frame(width: 120, height: 120)
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color("AppAccent").opacity(0.35), lineWidth: 1)
                }
                .compositingGroup()
                .shadow(color: Color("AppBackground").opacity(0.25), radius: 8, y: 4)

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color("AppAccent"), Color("AppPrimary")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
    }
}
