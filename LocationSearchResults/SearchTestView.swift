import SwiftUI
import MapKit

struct SearchTestView: View {
    @StateObject var infoService = LocationSearchService()
    
    @State var searchTextField = ""
    
    let center = CLLocationCoordinate2D(latitude: 34.0536909, longitude: -118.242766)
    let radius = 100.0

        var body: some View {
            VStack(alignment: .leading, spacing: 10) {
                Text("Search Tests").font(.largeTitle)
                TextField("Search", text: $searchTextField)
                HStack {
                    Button("Nearby Results") {
                        infoService.runNearbyLocationSearch(center: center, radius: radius)
                    }
                    Button("Keyword Results") {
                        infoService.runKeywordSearch(for: searchTextField)
                    }
                }
                List(infoService.resultItems, id:\.self) { item in
                    Text("\(item.name ?? "") - \(item.placemark)")
                }
            }.padding(10)
        }
}

struct SearchTestView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTestView()
    }
}
