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
    @State var shouldSuggest = true
    @State var showSuggestions = false
    
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
                    if shouldSuggest == true {
                        searchService.fetchSuggestions(with: searchTextField)
                    }
                    shouldSuggest = true
                
                    if searchTextField.isEmpty {
                        searchService.clearSuggestions()
                    }
                }.layoutPriority(1)
            
                .overlay(alignment:.bottom){
                    ZStack {
                        if showSuggestions {
                            suggestionsOverlay
                                .modifier(DropDownBackgroundModifier())
                                .transition(.scale(scale: 0, anchor: .topLeading))
                        }
                    }.alignmentGuide(.bottom) { $0[VerticalAlignment.top] }
                        
                }
                
       
        }.zIndex(3)
            .animation(menuAnimation, value: searchService.suggestedItems.count > 0)
            .onChange(of: searchService.suggestedItems.count) {newValue in
                withAnimation {
                    if newValue > 0 {
                        showSuggestions = true
                    } else {
                        showSuggestions = false
                    }
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
            VStack {
                ForEach(searchService.suggestedItems.prefix(numberOfItems), id:\.self) { item in

                        Button(action: {
                            shouldSuggest = false
                            runSearch(item)

                        }, label: {
                            CompletionItemRow(item: item).environmentObject(searchService)
                        })
                        Divider()
                    }

            }
    }
    
    //Note the animation only worked on the rectangle when it was in teh ZStack, not in the background
    //It does not appear to work on the VStack at all.
    // .scaleEffect(x: 1, y:showSuggestions ? 1 : 0, anchor: .top)
    var menuAnimation: Animation {
        Animation.easeIn(duration: 1.3)
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
