import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        FeatureStatusCard(
                            title: "Dynamic Peninsula",
                            systemImage: "capsule.fill",
                            isEnabled: appState.preferences.peninsula.isEnabled,
                            statusText: appState.preferences.peninsula.isEnabled ? "Enabled" : "Disabled"
                        )
                        FeatureStatusCard(
                            title: "Second Space",
                            systemImage: "square.stack.3d.up.fill",
                            isEnabled: appState.preferences.secondSpaceEnabled,
                            statusText: appState.preferences.secondSpaceEnabled ? "Configured" : "Not set up"
                        )
                        FeatureStatusCard(
                            title: "Appearance",
                            systemImage: "circle.lefthalf.filled",
                            isEnabled: true,
                            statusText: appState.preferences.appearance.mode.title
                        )
                        FeatureStatusCard(
                            title: "Privacy",
                            systemImage: "lock.fill",
                            isEnabled: appState.preferences.privacy.appLockEnabled,
                            statusText: appState.preferences.privacy.appLockEnabled ? "App Lock On" : "Open"
                        )
                    }

                    TestLabQuickLink()
                }
                .padding(20)
                .padding(.top, 8)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("DreamTweaks")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text("iPhone 12")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, DeviceLayout.topSafeArea * 0.4)
    }
}

struct FeatureStatusCard: View {
    let title: String
    let systemImage: String
    let isEnabled: Bool
    let statusText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: systemImage)
                .font(.title2)
                .foregroundStyle(.tint)

            Text(title)
                .font(.subheadline.weight(.semibold))

            HStack(spacing: 6) {
                Circle()
                    .fill(isEnabled ? Color.green : Color.gray)
                    .frame(width: 7, height: 7)
                Text(statusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06))
        )
    }
}

struct TestLabQuickLink: View {
    var body: some View {
        NavigationLink {
            TestLabView()
        } label: {
            HStack {
                Image(systemName: "hammer.fill")
                VStack(alignment: .leading) {
                    Text("DreamTweaks Test Lab")
                        .font(.subheadline.weight(.semibold))
                    Text("Simulate events without system integration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
