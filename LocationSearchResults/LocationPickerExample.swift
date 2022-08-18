//
//  LocationPickerExample.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/18/22.
//

import SwiftUI
import MapKit
import CoreLocationUI
import CoreLocation

struct LocationPickerExample: View {
    //@EnvironmentObject var searchService:LocationSearchService
    @State var mapItem:MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 34.0536909, longitude: -118.242766)))
    
    var body: some View {
        Form {
            LocationPicker(item: mapItem)
        }
    }
}

struct LocationPicker: View {
    //@EnvironmentObject var searchService:LocationSearchService
    @StateObject var searchService:LocationSearchService = LocationSearchService()
    @State var item:MKMapItem
    
    @State private var showingPopover = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a location")
            Button(
                action: { showingPopover.toggle() },
                label: {
                    LocationPickerLabelLayout(item: item)
                }).buttonStyle(.bordered).foregroundColor(.secondary)
                .popover(isPresented: $showingPopover) {
                    LocationPickerChooserContent().environmentObject(searchService)
                }
        }
    }
}

struct LocationPickerLabelLayout:View {
    @State var item:MKMapItem
    
    var body: some View {
        
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
            //                            .resizable()
            //                            .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Text(item.name ?? "No name provided")
                HStack {
                    Text("\(item.placemark.coordinate.latitude)" )
                    Text("\(item.placemark.coordinate.longitude)" )
                }
            }.layoutPriority(1)
        }.padding(5)
        
    }
}



struct LocationPickerChooserContent:View {
    @EnvironmentObject var searchService:LocationSearchService
    @Environment(\.presentationMode) var presentationMode
    
    var body:some View {
        VStack {
            HStack {
                Text("New Location")
                Button("Cancel") { close() }
            }
            HStack {
                LocationSearchField()
                
            }.zIndex(10)
            //List(1..<5) { _ in
            List(searchService.resultItems, id:\.self) { item in
                MapItemRow(item: item)
            }
        }.environmentObject(searchService)

    }
    
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
}



struct LocationPickerExample_Previews: PreviewProvider {
    static var previews: some View {
        LocationPickerExample()
    }
}
