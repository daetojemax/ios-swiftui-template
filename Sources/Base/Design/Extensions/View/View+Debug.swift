import SwiftUI

extension View {

    func debugAction(_ closure: () -> Void) -> Self {
        #if DEBUG
        closure()
        #endif
        return self
    }

    func debugPrint(_ value: Any) -> Self {
        debugAction {
            Swift.print(value)
        }
    }

    func debugModifier<T: View>(_ modifier: (Self) -> T) -> some View {
        #if DEBUG
        return modifier(self)
        #else
        return self
        #endif
    }

    public func debugBorder(color: Color = .red, width: CGFloat = 1) -> some View {
        debugModifier {
            $0.border(color, width: width)
        }
    }

    func debugBackground(color: Color = .red) -> some View {
        debugModifier {
            $0.background(color)
        }
    }

    func debugOverlay(_ text: String, color: Color = .red.opacity(0.7)) -> some View {
        debugModifier {
            $0.overlay(
                Text(text)
                    .font(.callout.bold())
                    .padding(4)
                    .background(color)
            )
        }
    }
}
