//
//  File.swift
//
//
//  Created by Labtanza on 8/12/22.
//

import Foundation
import MapKit




//TODO:https://developer.apple.com/documentation/mapkit/mklocalsearchcompleter

public final class LocationSearchService:ObservableObject {
    public init() {}

    @Published public var resultItems:[MKMapItem] = []
    
    
    public func runNearbyLocationSearch(center:CLLocationCoordinate2D, radius:Double) -> Void {
        Task { @MainActor in
            async let result = requestNearbyLocations(center: center, radius: radius)
            resultItems = await result
        }
    }
    
    func requestNearbyLocations(center:CLLocationCoordinate2D, radius:Double) async -> [MKMapItem] {
        var region = MKCoordinateRegion()
        region.center = center
        
        var locations:[MKMapItem] = []
        
        let request = MKLocalPointsOfInterestRequest(center: region.center, radius: radius)
        request.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [.restaurant, .cafe])
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            //print(response.mapItems)
            for item in response.mapItems {
                //print( item.name! )
                locations.append(item)
            }
        }
        catch {
            print("LSS requestNearbyLocations(): search failure \(error.localizedDescription)")
        }
        return locations
    }
    
    public func runKeywordSearch(for searchString:String) -> Void {
        Task { @MainActor in
            async let result = keywordSearch(for: searchString)
            resultItems = await result
        }
    }
    
    
    func keywordSearch(for searchString:String) async -> [MKMapItem] {
        var results:[MKMapItem] = []
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchString
        
        //Add region priority? searchRequest.region = yourMapView.region
        
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            for item in response.mapItems {
                results.append(item)
            }
        } catch {
            print("LSS keywordSearch(): search failure \(error.localizedDescription)")
        }
        
        return results
    }
}
