import SwiftUI

struct SparklineView: View {
    let values: [Double]
    let accentColor: Color

    var body: some View {
        if values.count >= 2 {
            SparklineShape(values: values)
                .stroke(accentColor, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
        } else {
            Rectangle()
                .fill(Color.clear)
        }
    }
}

struct SparklineShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        guard values.count >= 2 else { return Path() }

        let minVal = values.min() ?? 0
        let maxVal = values.max() ?? 1
        let range = maxVal - minVal
        let safeRange = range == 0 ? 1 : range

        var path = Path()
        let stepX = rect.width / CGFloat(values.count - 1)

        for (index, value) in values.enumerated() {
            let x = CGFloat(index) * stepX
            let y = rect.height - ((CGFloat(value - minVal) / CGFloat(safeRange)) * rect.height)

            if index == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return path
    }
}
