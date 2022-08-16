////
////  ExampleSuggestionText.swift
////  LocationSearchResults
////
////  Created by Labtanza on 8/15/22.
////
//
//import SwiftUI
//
//
//struct SellerbuddyAutoCompleteView: View {
//    
//    @State private var popupTagsPresented = false
//    @State var variableLinkedTo = ""
//
//    var body: some View {
//
//        TextField("PlaceholderText", text: $variableLinkedTo)
//
//    .onChange(of: variableLinkedTo, perform: { newTag in
//
//        //Do something with new tag to know when you want to show or not the popup, here assuming always
//
//        popupTagsPresented = true
//
//    })
//
//    .popover(isPresented: $popupTagsPresented, arrowEdge: .top) {
//        
//        let filteredMatches = ["some stuff", "somethingElse"]//Array of items to show (likely you’d grab it from Core Data / some model function)
//        
//        VStack(alignment: .leading, spacing: 4){
//            
//            ForEach(filteredMatches) { suggestion in
//                
//                Button{
//                    
//                    //When user clicks on the suggestion, replace text with suggestion and process it
//                    
//                    variableLinkedTo = suggestion.name
//                    
//                    //processText()
//                    
//                }label: {
//                    
//                    Label(suggestion.name ?? “”, systemImage: “someIcon”)
//                    
//                }
//                
//                .buttonStyle(.borderless)
//                
//            }
//            
//        }.padding(10)
//    }
//    }
//}
//
//struct SellerbuddyAutoCompleteView_Previews: PreviewProvider {
//    static var options = [String](arrayLiteral: "Afghanistan","America")
//    static var previews: some View {
//        SellerbuddyAutoCompleteView()
//    }
//    
//}
//
