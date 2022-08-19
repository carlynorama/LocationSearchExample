//
//  ContentView.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/13/22.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var searchService = LocationSearchService()
    @State var location:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 34.0536909, longitude: -118.242766)))

    var body: some View {
        TabView {

            LocationPickerExample()
                .tabItem {
                    Label("Location Picker", systemImage: "globe")
                }
            LocationPickerChooserContent(location:$location, style: .searchWithSuggestedValues(items: [location]))
                .tabItem {
                    Label("Chooser", systemImage: "globe")
                }
            LocationSearchFieldExampleView()
                .tabItem {
                    Label("Suggested Search", systemImage: "globe")
                }
            SearchTestView()
                //.badge(2)
                .tabItem {
                    Label("Search", systemImage: "globe")
                }

            SearchableFieldView()
                .tabItem {
                    Label("Searchable", systemImage: "globe")
                }
        }.environmentObject(searchService)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
