import SwiftUI
import MapKit

struct SearchTestView: View {
    @EnvironmentObject var infoService:LocationSearchService
    
    @State var searchTextField = "New"
    
    let center = CLLocationCoordinate2D(latitude: 34.0536909, longitude: -118.242766)
    let radius = 100.0

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Search Tests").font(.largeTitle)
                TextField("Search", text: $searchTextField)
                HStack {
                    Button("Landmarks Nearby") {
                        infoService.runNearbyLocationSearch(center: center, radius: radius)
                    }
                    Spacer()
                    Button("Keyword") {
                        infoService.runKeywordSearch(for: searchTextField)
                    }
                    Spacer()
                    Button("Coffee") {
                        infoService.runCoffeeSearch()
                    }
                }
                List(infoService.resultItems, id:\.self) { item in
                    MapItemRow(item: item)
                }
            }.padding(10)
        }
}



struct SearchTestView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTestView().environmentObject(LocationSearchService())
    }
}
