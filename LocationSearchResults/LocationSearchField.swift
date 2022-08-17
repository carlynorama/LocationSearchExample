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
    //@State var showSuggestions = false
    
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
                       // if showSuggestions {
                            suggestionsOverlay
                                .modifier(DropDownBackgroundModifier())
                                
                                //.transition(.scale(scale: 0, anchor: .topLeading))
                            //.transition(clipTransition)
                        //.scaleEffect(x: 1, y:showSuggestions ? 1 : 0, anchor: .top)
                            //.animation(menuAnimation, value: showSuggestions)
                       // }
                    }.alignmentGuide(.bottom) { $0[VerticalAlignment.top] }
                      //  .scaleEffect(x: 1, y:showSuggestions ? 1 : 0)
                }
                
       
        }.zIndex(3)
//            .animation(menuAnimation, value: showSuggestions)
//            .onChange(of: searchService.suggestedItems.count) { newValue in
//
//                if newValue > 0 {
//                        withAnimation {
//                            showSuggestions = true
//                        }
//                    } else {
//                        withAnimation {
//                            showSuggestions = false
//                        }
//                    }
//
//            }

    }
    func runSearch(_ suggestion:MKLocalSearchCompletion) {
        textObserver.overrideText(suggestion.id)
        searchService.clearSuggestions()
        searchService.runSuggestedItemSearch(for: suggestion)
        searchService.clearSuggestions()
    }
    
    @ViewBuilder private var suggestionsOverlay: some View {
        VStack(alignment: .leading) {
            ForEach(searchService.suggestedItems.prefix(numberOfItems), id:\.self) { item in
            
                    Button(action: {
                        shouldSuggest = false
                        runSearch(item)
                        
                    }, label: {
                        SuggestionItemRow(item: item).environmentObject(searchService)
                    })
                    Divider()
                }
            
            }
    }
    
    struct SuggestionItemRow: View {
        @EnvironmentObject var infoService:LocationSearchService
        let item:MKLocalSearchCompletion
        
    //        Has no effect on layout issues
    //        let charset = CharacterSet.alphanumerics.inverted
    //            .trimmingCharacters(in: charset)
        
        var body: some View {
        
                VStack(alignment: .leading) {
                    Text("\(item.title)")
                    Text("\(item.subtitle)").font(.caption)
                }
        }
    }
    
    //Note the animation only worked on the rectangle when it was in teh ZStack, not in the background
    //It does not appear to work on the VStack at all.
    // .scaleEffect(x: 1, y:showSuggestions ? 1 : 0, anchor: .top)
//    var menuAnimation: Animation {
//        Animation.easeInOut(duration: 4)
//    }
//    
//    struct ClipEffect: ViewModifier {
//        var value: CGFloat
//
//        func body(content: Content) -> some View {
//            content
//                .clipShape(RoundedRectangle(cornerRadius: 100*(1-value)).scale(value))
//        }
//    }
//
//
//        var clipTransition: AnyTransition {
//            .modifier(
//                active: ClipEffect(value: 0),
//                identity: ClipEffect(value: 1)
//            )
//        }
    
    
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
