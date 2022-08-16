//
//  AlignmentTestsView.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/16/22.
//

import SwiftUI

//extension VerticalAlignment {
//    struct CustomAlignment: AlignmentID {
//        static func defaultValue(in context: ViewDimensions) -> CGFloat {
//            return context[VerticalAlignment.center]
//        }
//    }
//
//    static let custom = VerticalAlignment(CustomAlignment.self)
//    
//}


struct AlignmentTestsView: View {
    var body: some View {
        VStack {
//            HStack(alignment: .custom) {
//                        Image(systemName: "star")
//                        VStack(alignment: .leading) {
//                            Text("Toronto")
//                            Text("Paris")
//                            Text("London")
//                                .alignmentGuide(.custom) { $0[VerticalAlignment.top] }
//                            Text("Madrid")
//                        }
//                    }
//            Rectangle()
//                .fill(Color.gray)
//                .frame(width: 85, height: 175)
//                .overlay(
//                    Circle()
//                      .stroke(Color.black,
//                            style: StrokeStyle(
//                                 lineWidth: 2,
//                                 lineCap: .round,
//                                 lineJoin: .miter,
//                                 miterLimit: 0,
//                                 dash: [5, 10],
//                                 dashPhase: 0
//                            ))
//                      .frame(width: 85, height: 85)
//                      .alignmentGuide(.top) { $0[VerticalAlignment.center] } // << this !!
//                , alignment: .top)
            Text("This message needs and overlay.")
                .overlay(alignment: .bottom) {
                    VStack {
                        Text("We have some overlay text.")
                        Text("We have a second line of overlay text.")
                    }.alignmentGuide(.bottom) { $0[VerticalAlignment.top] }
                }
        }
    }
}

struct AlignmentTestsView_Previews: PreviewProvider {
    static var previews: some View {
        AlignmentTestsView()
    }
}
