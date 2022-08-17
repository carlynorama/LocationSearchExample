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
    //Custom alignment guide that can swap it from a drop down to a pop up
    let numberOfItems = 5  //based on space? preference in init?
    
    var body: some View {
        HStack {
            Image(systemName: "location.magnifyingglass").foregroundColor(.secondary)
            TextField(promptText, text: $textObserver.searchText)
                .textFieldStyle(LocationSearchTextFieldStyle())
                .focused($searchIsFocused)
                .onReceive(textObserver.$debouncedText) { (val) in
                    searchTextField = val
                }
                .onChange(of: $searchTextField.wrappedValue) { text in
                    if searching == true {
                        searchService.fetchSuggestions(with: searchTextField)
                    }
                    searching = true
                    
                }.layoutPriority(1)
                .overlay(alignment:.bottom){
                    Group {
                        suggestionsOverlay
                            .modifier(DropDownBackgroundModifier())
                            
                    }.alignmentGuide(.bottom) { $0[VerticalAlignment.top] }
                }
                
       
        }.zIndex(3)
            
        

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
        
        //.offset(y:textfieldHeight)
                
        }
    }
    
    enum StyleConstants {
        static let inset = 5.0
        static let menuBackgroundOpacity = 0.5
    }
    
    struct DropDownBackgroundModifier: ViewModifier {

        func body(content: Content) -> some View {
            content
                .background(Rectangle()
                    .fill(Color(UIColor.systemGray6))
                    .opacity(StyleConstants.menuBackgroundOpacity)
                    //.foregroundStyle(.ultraThinMaterial)
                )
                .padding(EdgeInsets(top: 0, leading: StyleConstants.inset, bottom: 0, trailing: StyleConstants.inset))
                
        }
    }
    
    //Rectangle().modifier(DropDownBackgroundModifier())
    
    struct LocationSearchTextFieldStyle: TextFieldStyle {
        func _body(configuration: TextField<_Label>) -> some View {
            configuration
                .padding(StyleConstants.inset)
                .background(RoundedRectangle(cornerRadius: StyleConstants.inset).fill(Color(UIColor.systemGray6)))
        }
    }
}



struct LocationSearchField_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchField().environmentObject(LocationSearchService())
    }
}
