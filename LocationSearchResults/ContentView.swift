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
            SearchTestView()
                //.badge(2)
                .tabItem {
                    Label("Search", systemImage: "tray.and.arrow.down.fill")
                }
            AutoCompleteView()
                .tabItem {
                    Label("Suggested Search", systemImage: "tray.and.arrow.up.fill")
                }
        }.environmentObject(searchService)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
