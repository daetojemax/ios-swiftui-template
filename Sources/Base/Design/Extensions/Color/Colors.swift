import SwiftUI

public extension Color {
    // MARK: - Base Palette
    //
    // The template intentionally keeps only a tiny demo palette in asset catalogs:
    // `black`, `white`, and `purple`. Use opacity variants at call sites for demo
    // secondary states instead of adding template-specific color assets.

    enum Fill {
        public static var black: Color {
            Color("black", bundle: .module)
        }

        public static var white: Color {
            Color("white", bundle: .module)
        }

        public static var purple: Color {
            Color("purple", bundle: .module)
        }
    }
}
