////
////  AutoCompleteView.swift
////  LocationSearchResults
////
////  Created by Labtanza on 8/13/22.
////
//
//import SwiftUI
//import MapKit
//import LocationServices
//
//struct AutoCompleteView: View {
//    @EnvironmentObject var infoService:LocationSearchService
//    
//    @State var searchTextField = "New"
//    
//    var body: some View {
//            VStack(alignment: .leading, spacing: 10) {
//                Text("Search Tests").font(.largeTitle)
//                DebouncingTextField("Search", text: $searchTextField, debounceDelay: 0.5)            .onChange(of: searchTextField) { text in
//                    infoService.fetchSuggestions(with: searchTextField)
//                }
////                HStack {
////                    Button("Keyword") {
////                        infoService.runKeywordSearch(for: searchTextField)
////                    }
////                    Spacer()
////                    Button("Coffee") {
////                        infoService.runCoffeeSearch()
////                    }
////                }
//                List(infoService.suggestedItems, id:\.self) { item in
//                    CompletionItemRow(item: item).environmentObject(infoService)
//                }
//                
//                List(infoService.resultItems, id:\.self) { item in
//                    MapItemRow(item: item)
//                }
//            }.padding(10)
//    }
//    
//    
//}
//
//
//
//struct AutoCompleteView_Previews: PreviewProvider {
//    static var previews: some View {
//        AutoCompleteView().environmentObject(LocationSearchService())
//    }
//}
