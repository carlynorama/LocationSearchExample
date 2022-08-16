//
//  LocationSearchField.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//

import SwiftUI
import MapKit



struct LocationSearchField: View {
    @EnvironmentObject var searchService:LocationSearchService
    
    var promptText:String = "Search for a location"
    //@Binding var debouncedText : String
    @StateObject private var textObserver:TextFieldObserver = TextFieldObserver(delay: 0.2)
    
    @State var searchTextField = ""
    @State var searching = true
    
    @FocusState private var searchIsFocused: Bool
    
    //TODO: Layout
    let textfieldHeight = 25.0
    let numberOfItems = 5  //based on space?
    
    var body: some View {
        VStack {
        
                TextField(promptText, text: $textObserver.searchText)
                    .focused($searchIsFocused)
                    .onReceive(textObserver.$debouncedText) { (val) in
                        searchTextField = val
                    }
                    .onChange(of: $searchTextField.wrappedValue) { text in
                        if searching == true {
                            searchService.fetchSuggestions(with: searchTextField)
                        }
                        searching = true
                        
                    }.border(.gray)
                    
            .layoutPriority(1)
                .overlay(alignment:.topLeading){
                   suggestionsOverlay.backgroundStyle(.regularMaterial)
            }.zIndex(3)
                
            Spacer()
            List(searchService.resultItems, id:\.self) { item in
                MapItemRow(item: item)
            }
        }
        

    }
    func runSearch(_ suggestion:MKLocalSearchCompletion) {
        textObserver.overrideText(suggestion.id)
        searchService.clearSuggestions()
        searchService.runSuggestedItemSearch(for: suggestion)
        searchService.clearSuggestions()
    }
    
    @ViewBuilder private var suggestionsOverlay: some View {
        if searchService.suggestedItems.count > 0 {
        ZStack {
            //Rectangle().fill(.blue)
              //  .frame(minWidth: 100, minHeight: 100)
            Rectangle().foregroundStyle(.ultraThinMaterial)
            VStack {
                ForEach(searchService.suggestedItems.prefix(numberOfItems), id:\.self) { item in
                    Button(action: {
                       searching = false
                       runSearch(item)
                       
                    }, label: {
                    CompletionItemRow(item: item).environmentObject(searchService)
                    })
                    Divider()
                }
            }
        }
        
        .offset(y:textfieldHeight)
                
        }
    }

    
}

struct LocationSearchField_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchField().environmentObject(LocationSearchService())
    }
}
