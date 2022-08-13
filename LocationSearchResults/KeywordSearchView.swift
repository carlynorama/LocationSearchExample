//
//  KeywordSearchView.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/12/22.
//

import SwiftUI

struct KeywordSearchView: View {
    @StateObject var infoService = LocationSearchService()
    let searchTerm = "new"

        var body: some View {
            List(infoService.resultItems, id:\.self) { item in
                Text(item.name ?? "No name")
            }.onAppear {
                    infoService.runKeywordSearch(for: searchTerm)
                }
        }
}

struct KeywordSearchView_Previews: PreviewProvider {
    static var previews: some View {
        KeywordSearchView()
    }
}
