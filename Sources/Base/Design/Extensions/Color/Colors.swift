import SwiftUI

public extension Color {
    // MARK: - Fill Colors

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

        public static var black2: Color {
            Color("black2", bundle: .module)
        }

        public static var errorToast: Color {
            Color("error_toast", bundle: .module)
        }

        public static var chipBackground: Color {
            Color("chip_background", bundle: .module)
        }

        public static var lime: Color {
            Color("lime", bundle: .module)
        }
    }

    // MARK: - Text Colors

    enum Text {
        public static var white: Color {
            Color("white", bundle: .module)
        }

        public static var lime: Color {
            Color("lime", bundle: .module)
        }

        public static var grey4: Color {
            Color("grey4", bundle: .module)
        }

        public static var grey6: Color {
            Color("grey6", bundle: .module)
        }

        public static var primary48: Color {
            Color("primary48", bundle: .module)
        }

        public static var grey0: Color {
            Color("grey0", bundle: .module)
        }

        public static var grey2: Color {
            Color("grey2", bundle: .module)
        }
    }

    // MARK: - Background Colors

    enum BG {
        public static var primary: Color {
            Color("white", bundle: .module)
        }

        public static var secondary: Color {
            Color("bg_secondary", bundle: .module)
        }
    }
}
