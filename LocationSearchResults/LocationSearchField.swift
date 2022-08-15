//
//  LocationSearchField.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//

import SwiftUI

struct LocationSearchField: View {
    @EnvironmentObject var searchService:LocationSearchService
    
    @State var searchTextField = "New"
    
    var body: some View {
        VStack {
            DebouncingTextField("Search", text: $searchTextField, debounceDelay: 0.5)            .onChange(of: searchTextField) { text in
                searchService.fetchSuggestions(with: searchTextField)
            }.border(.gray)
                .overlay(alignment:.topLeading){
                    if searchService.suggestedItems.count > 0 {
                    ZStack {
                        Rectangle().fill(.blue)
                            .frame(minWidth: 100, minHeight: 100)
                        VStack {
                            ForEach(searchService.suggestedItems.prefix(9), id:\.self) { item in
                                CompletionItemRow(item: item).environmentObject(searchService)
                                Divider()
                            }
                        }
                    }
                }
            }
//            Spacer()
//            List(searchService.resultItems, id:\.self) { item in
//                MapItemRow(item: item)
//            }
        }
    }
    
    
}

struct LocationSearchField_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchField().environmentObject(LocationSearchService())
    }
}
