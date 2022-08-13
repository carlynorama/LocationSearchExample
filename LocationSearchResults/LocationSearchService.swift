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
        
        let searchRequest = MKLocalPointsOfInterestRequest(center: region.center, radius: radius)
        searchRequest.pointOfInterestFilter = MKPointOfInterestFilter(excluding: [.restaurant, .cafe])
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            for item in response.mapItems {
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
        //Add region priority? searchRequest.region = yourMapView.region
        
        var locations:[MKMapItem] = []
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchString
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            for item in response.mapItems {
                locations.append(item)
            }
        } catch {
            print("LSS keywordSearch(): search failure \(error.localizedDescription)")
        }
        
        return locations
    }
}
