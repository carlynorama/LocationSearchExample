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
//        VStack {
//            Button("Toggle Dropdown") {
//                withAnimation {
//                    showSuggestions.toggle()
//                }
//            }
//            .buttonStyle(.borderedProminent)
//            .padding(5)
//        }
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
                        withAnimation {
                            showSuggestions = false
                        }
                        searchService.clearSuggestions()
                        
                    }
                    
                }.layoutPriority(1)
            
                .overlay(alignment:.bottom){
                    ZStack {
                        if showSuggestions {
                            ZStack {
                                suggestionsList.modifier(DropDownBackgroundModifier())
                            }.transition(menuTransition)
                        }
                    }.alignmentGuide(.bottom) { $0[VerticalAlignment.top] }
                    
                }
            
        } .zIndex(3)
            .onChange(of: searchService.suggestedItems.count) { newValue in
                if newValue > 0 {
                    withAnimation {
                        showSuggestions = true
                    }
                } else {
                    withAnimation {
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
    

    
    struct SuggestionItemRow: View {
        let item:MKLocalSearchCompletion
        var body: some View {
        
                VStack(alignment: .leading) {
                    Text("\(item.title)")
                    Text("\(item.subtitle)").font(.caption)
                }
        }
    }
    
    var menuTransition:AnyTransition {
        //AnyTransition.scale(scale: 2, anchor: UnitPoint(x: 1, y: 0))
        AnyTransition.opacity.combined(with: .move(edge: .top)).combined(with: verticalClipTransition)
    }
    
    struct VerticalClipEffect:ViewModifier {
        var value: CGFloat
        
        func body(content: Content) -> some View {
            content
                .clipShape(Rectangle().scale(x: 1, y: value, anchor: .top))
        }
    }
    
    var verticalClipTransition:AnyTransition {
        .modifier(
            active: VerticalClipEffect(value: 0),
            identity: VerticalClipEffect(value: 1)
        )
    }

    
    @ViewBuilder private var suggestionsList: some View {
        VStack(alignment: .leading) {
            ForEach(searchService.suggestedItems.prefix(numberOfItems), id:\.self) { item in
                    Button(action: {
                        shouldSuggest = false
                        runSearch(item)

                    }, label: {
                        SuggestionItemRow(item: item)
                    })
                    Divider()
                }

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
                .transition(.opacity)
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
