//
//  PlacemarkReturnTest.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/12/22.
//

import SwiftUI
import MapKit

struct PlacemarkReturnTest: View {
    @StateObject var infoService = LocationSearchService()
    let center = CLLocationCoordinate2D(latitude: 34.0536909, longitude: -118.242766)
    let radius = 100.0

        var body: some View {
            List(infoService.resultItems, id:\.self) { item in
                Text(item.name ?? "No name")
            }.onAppear {
                    infoService.runNearbyLocationSearch(center: center, radius: radius)
                }
        }
}

//
//class PlacemarkService:ObservableObject {
//
//    @Published var locations:[CLPlacemark] = []
//
//    func requestLocations() -> Void {
//        Task { @MainActor in
//            async let result = requestNearbyLocations()
//            locations = await result
//        }
//    }
//
//    func requestNearbyLocations() async -> [CLPlacemark] {
//        var region = MKCoordinateRegion()
//        region.center = CLLocationCoordinate2D(latitude: 34.0536909, longitude: -118.242766)
//
//        var locations:[CLPlacemark] = []
//
//        let request = MKLocalPointsOfInterestRequest(center: region.center, radius: 100.0)
//        request.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [.restaurant, .cafe])
//        let search = MKLocalSearch(request: request)
//
//        do {
//            let response = try await search.start()
//            print(response.mapItems)
//            for item in response.mapItems {
//                print( item.name! )
//                locations.append(item.placemark)
//            }
//        }
//        catch {
//            print(error)
//        }
//        return locations
//    }
//}


struct PlacemarkReturnTest_Previews: PreviewProvider {
    static var previews: some View {
        PlacemarkReturnTest()
    }
}
