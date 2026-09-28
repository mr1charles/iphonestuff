import CoreGraphics

/// Layout constants for the iPhone 12 (6.1", notch, no Dynamic Island).
/// DreamTweaks targets this geometry explicitly rather than a Dynamic Island device.
enum DeviceLayout {
    /// Logical point size for iPhone 12 / 12 Pro (portrait).
    static let logicalSize = CGSize(width: 390, height: 844)

    /// Physical pixel target referenced in the spec (1170 x 2532 @3x).
    static let physicalPixelSize = CGSize(width: 1170, height: 2532)

    /// Approximate notch size in points for iPhone 12 (public-API safe area
    /// gives us the real inset at runtime; this is used for prototype
    /// artwork sizing only, e.g. the compact Dynamic Peninsula pill).
    static let notchSize = CGSize(width: 209, height: 30)

    /// Corner radius approximating the iPhone 12 display corners, used for
    /// chrome that hugs the screen edge (e.g. Second Space transition mask).
    static let screenCornerRadius: CGFloat = 40

    /// Top safe-area inset baseline for iPhone 12 in portrait.
    static let topSafeArea: CGFloat = 47

    static let bottomSafeArea: CGFloat = 34
}
