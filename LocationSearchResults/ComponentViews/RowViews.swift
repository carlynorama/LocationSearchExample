//
//  RowViews.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//

import SwiftUI
import MapKit


//struct MapItemRow: View {
//    let item:MKMapItem
//
//    var body: some View {
//        VStack {
//            Text("\(item.name ?? "No name")")
//            Text("placemark: \(item.placemark)").font(.caption)
//        }
//    }
//}

struct MapItemRow:View {
    let item:MKMapItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name ?? "No name provided")
                Text(descriptionFromPlacemark(item.placemark))
                HStack {
                    Text("\(item.placemark.coordinate.latitude)" )
                    Text("\(item.placemark.coordinate.longitude)" )
                }
            }
        }
    }
        
        func descriptionFromPlacemark(_ placemark:CLPlacemark) -> String {
            let firstItem = placemark.locality //placemark.areasOfInterest?[0] ?? placemark.locality
            let availableInfo:[String?] = [firstItem, placemark.administrativeArea, placemark.country]
            let string = availableInfo.compactMap{ $0 }.joined(separator: ", ")
            return string
        }
}



struct CompletionItemRow: View {
    @EnvironmentObject var infoService:LocationSearchService
    let item:MKLocalSearchCompletion
    
//        Has no effect on layout issues
//        let charset = CharacterSet.alphanumerics.inverted
//            .trimmingCharacters(in: charset)
    
    var body: some View {
        HStack {
            VStack {
                Text("\(item.title)")
                Text("\(item.subtitle)").font(.caption)
            }
            Button("") {
                infoService.runSuggestedItemSearch(for: item)
            }
        }
    }
}
