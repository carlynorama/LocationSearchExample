//
//  ContentView.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/13/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var searchService = LocationSearchService()

    var body: some View {
        TabView {
            LocationPickerExample()
                .tabItem {
                    Label("Location Picker", systemImage: "globe")
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
