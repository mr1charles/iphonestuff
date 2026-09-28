import SwiftUI

struct SetupFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var page: Int = 0

    private let totalPages = 5

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(white: 0.08)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            TabView(selection: $page) {
                WelcomeSetupPage(onContinue: { advance() })
                    .tag(0)
                AppearanceSetupPage(mode: $appState.preferences.appearance.mode, onContinue: { advance() })
                    .tag(1)
                DynamicPeninsulaSetupPage(isEnabled: $appState.preferences.peninsula.isEnabled, onContinue: { advance() })
                    .tag(2)
                SecondSpaceSetupPage(isEnabled: $appState.preferences.secondSpaceEnabled, onContinue: { advance() })
                    .tag(3)
                FinishSetupPage(onStart: { appState.completeOnboarding() })
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: page)

            VStack {
                Spacer()
                SetupPageIndicator(current: page, total: totalPages)
                    .padding(.bottom, 28)
            }
        }
        .foregroundStyle(.white)
    }

    private func advance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            page = min(page + 1, totalPages - 1)
        }
    }
}

struct SetupPageIndicator: View {
    let current: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == current ? Color.white : Color.white.opacity(0.25))
                    .frame(width: index == current ? 18 : 6, height: 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: current)
            }
        }
    }
}

struct SetupContinueButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(.white, in: Capsule())
                .foregroundStyle(.black)
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 90)
    }
}
