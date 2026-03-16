import SwiftUI

public struct SegmentedControl: View {
    private let titles: [String]
    @Binding var selectedIndex: Int

    public init(titles: [String],
                selectedIndex: Binding<Int>)
    {
        self.titles = titles
        _selectedIndex = selectedIndex
    }

    public var body: some View {
        HStack {
            ForEach(0 ..< titles.count, id: \.self) { index in
                Button {
                    withAnimation(.smooth(duration: 0.5)) {
                        selectedIndex = index
                    }
                } label: {
                    Text(titles[index])
                        .padding(5)
                        .foregroundColor(Color.Fill.black)
                        .fill(.horizontal)
                }
                .matchedGeometryEffect(
                    id: index,
                    in: segmentedControl
                )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.Fill.white)
                .matchedGeometryEffect(
                    id: selectedIndex,
                    in: segmentedControl,
                    isSource: false
                )
        )
        .padding(3)
        .background(Color.Fill.chipBackground)
        .clipShape(
            RoundedRectangle(cornerRadius: 30)
        )
        .buttonStyle(.plain)
    }

    @Namespace private var segmentedControl
}
