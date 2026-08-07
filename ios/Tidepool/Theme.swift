import SwiftUI

/// The single palette, matching `web/src/styles.css`. Hard-coded rather than
/// asset-catalogue colours so the two clients can be diffed by eye.
enum Theme {
    static let ink = Color(red: 0.024, green: 0.075, blue: 0.122)
    static let ink2 = Color(red: 0.043, green: 0.118, blue: 0.180)
    static let line = Color(red: 0.090, green: 0.212, blue: 0.294)
    static let text = Color(red: 0.910, green: 0.957, blue: 0.973)
    static let muted = Color(red: 0.561, green: 0.690, blue: 0.761)
    static let aqua = Color(red: 0.239, green: 0.855, blue: 0.843)
    static let deep = Color(red: 0.106, green: 0.435, blue: 0.561)
    static let sun = Color(red: 1.0, green: 0.831, blue: 0.475)
    static let coral = Color(red: 1.0, green: 0.541, blue: 0.420)

    static func tint(for rating: Rating) -> Color {
        switch rating {
        case .epic: return aqua
        case .good: return sun
        case .fair: return muted
        case .poor: return coral
        }
    }
}
