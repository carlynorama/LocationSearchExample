//
//  File.swift
//
//
//  Created by Labtanza on 8/12/22.
//

import Foundation
import MapKit
import SwiftUI

extension MKLocalSearchCompletion:Identifiable {
    public var id:String {
        self.title+" "+self.subtitle
    }
}

public final class LocationSearchService:NSObject, ObservableObject {
    
    public override init() {
        self.searchCompleter = MKLocalSearchCompleter()
        super.init()
        
        searchCompleter.delegate = self
    }

    @Published public private(set) var resultItems:[MKMapItem] = []
    
    var searchCompleter:MKLocalSearchCompleter
    @Published public private(set) var suggestedItems:[MKLocalSearchCompletion] = []
    
    @Published public private(set) var recentSearches:[String] = []

    
    public func clearSuggestions() {
        suggestedItems = []
    }
    
    public func clearResults() {
        resultItems = []
    }
    
    public func clearRecentSearhes() {
        recentSearches = []
    }
    
    public func addToRecentSearches(_ string:String) {
        recentSearches.append(string)
    }
    
    
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
        
        var locations:[MKMapItem] = []
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchString
        searchRequest.region = MKCoordinateRegion(.world)
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
    
    public func runCoffeeSearch() {
        Task { @MainActor in
            async let result = coffeSearch()
            resultItems = await result
        }
    }
    
    func coffeSearch() async -> [MKMapItem] {
        
        var locations:[MKMapItem] = []
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = "coffee"
        let testRegion = searchRequest.region
        print("LSS coffeeSearch region: \(testRegion)")
        
        let search = MKLocalSearch(request: searchRequest)
        
        do {
            let response = try await search.start()
            for item in response.mapItems {
                locations.append(item)
//                if let name = item.name,
//                   let location = item.placemark.location {
//                    print("\(name): \(location.coordinate.latitude),\(location.coordinate.longitude)")
//                }
            }
        } catch {
            print("LSS coffeeSearch(): search failure \(error.localizedDescription)")
        }
        
        return locations
    }
    
    
    
    
    //use with debouncing text field.
    public func fetchSuggestions(with searchTerm:String) {
        //searchCompleter is watching queryFragment itself.
        searchCompleter.queryFragment = searchTerm
    }
    
    public func runSuggestedItemSearch(for suggestedCompletion: MKLocalSearchCompletion) {
        Task { @MainActor in
            async let result = suggestedItemSearch(for: suggestedCompletion)
            resultItems = await result
        }
    }

    private func suggestedItemSearch(for suggestedCompletion: MKLocalSearchCompletion) async -> [MKMapItem] {
        var locations:[MKMapItem] = []
        
        let searchRequest = MKLocalSearch.Request(completion: suggestedCompletion)
        let search = MKLocalSearch(request: searchRequest)
        do {
            let response = try await search.start()
            for item in response.mapItems {
                locations.append(item)
                if let name = item.name,
                   let location = item.placemark.location {
                    print("\(name): \(location.coordinate.latitude),\(location.coordinate.longitude)")
                }
            }
        } catch {
            print("LSS suggestedItemSearch(): search failure \(error.localizedDescription)")
        }
        return locations
    }
    
}

extension LocationSearchService: MKLocalSearchCompleterDelegate {
    
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Depending on what you're searching, you might need to filter differently or
        // remove the filter altogether. Filtering for an empty Subtitle seems to filter
        // out a lot of places and only shows cities and countries.
        //print("success")
        //self.searchResults = completer.results.filter({ $0.subtitle == "" })
        //self.status = completer.results.isEmpty ? .noResults : .result
        print("success")
        dump(completer.results)
        self.suggestedItems = completer.results
    }

    public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("failed", error)
        //self.status = .error(error.localizedDescription)
    }
}

//func completerDidUpdateResult(_ completer: MKLocalSearchComleter) {
//  print("succeeded")
//  dump(completer.results)
//
//  let search = MKLocalSearch(request: .init(completion: completer.results[0]))
//}
