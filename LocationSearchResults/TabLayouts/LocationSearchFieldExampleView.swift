//
//  LocationSearchFieldExampleView.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/15/22.
//

import SwiftUI
import LocationServices

struct LocationSearchFieldExampleView: View {
    @EnvironmentObject var infoService:LocationSearchService
    
    @State var searchTextField = "New"
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Search Tests").font(.largeTitle)
            LocationSearchField()
            List(infoService.resultItems, id:\.self) { item in
                MapItemRow(item: item)
            }
        }.padding(10)
        .environmentObject(infoService)
    }
}



struct LocationSearchFieldExampleView_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchFieldExampleView().environmentObject(LocationSearchService())
    }
}
