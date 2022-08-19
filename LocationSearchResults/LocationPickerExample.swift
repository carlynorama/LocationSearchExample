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
            LocationPicker(item: $mapItem, style: .searchOnly)
            LocationPicker(item: $mapItem, style: .deviceLocation)
        }
    }
}

enum LocationPickerStyle {
    case deviceLocation
    case searchOnly
}


struct LocationPicker: View {
    
    //@EnvironmentObject var searchService:LocationSearchService
    @StateObject var searchService:LocationSearchService = LocationSearchService()
    @Binding var item:MKMapItem
    let style:LocationPickerStyle
    
    @State private var showingPopover = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Choose a location")
            
            switch style {
            case .deviceLocation:
                HStack {
                    Button(
                        action: { showingPopover.toggle() },
                        label: {
                            LocationPickerLabelLayout(item: $item)
                        }).buttonStyle(.bordered).foregroundColor(.secondary)
                        .popover(isPresented: $showingPopover) {
                            LocationPickerChooserContent(location: $item).environmentObject(searchService)
                        }
                    CurrentLocationButton(locationRequester: { print("go fetch location") })
                    
                }
            case .searchOnly:
                Button(
                    action: { showingPopover.toggle() },
                    label: {
                        LocationPickerLabelLayout(item: $item)
                    }).buttonStyle(.bordered).foregroundColor(.secondary)
                    .popover(isPresented: $showingPopover) {
                        LocationPickerChooserContent(location: $item).environmentObject(searchService)
                    }
            }
        }
    }
    

}

struct LocationPickerLabelLayout:View {
    @Binding var item:MKMapItem
    
    var body: some View {
        
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
            //                            .resizable()
            //                            .aspectRatio(contentMode: .fit)
            VStack(alignment: .leading) {
                Text(item.name ?? "No name provided")
                Text(descriptionFromPlacemark(item.placemark))
//                HStack {
//                    Text("\(item.placemark.coordinate.latitude)" )
//                    Text("\(item.placemark.coordinate.longitude)" )
//                }
            }.layoutPriority(1)
        }.padding(5)

    }
    func descriptionFromPlacemark(_ placemark:CLPlacemark) -> String {
        let firstItem = placemark.locality //placemark.areasOfInterest?[0] ?? placemark.locality
        let availableInfo:[String?] = [firstItem, placemark.administrativeArea, placemark.country]
        var string = availableInfo.compactMap{ $0 }.joined(separator: ", ")
        if string.isEmpty {
            string = "\(item.placemark.coordinate.latitude), \(item.placemark.coordinate.longitude)"
        }
        return string
    }
}



struct LocationPickerChooserContent:View {
    @EnvironmentObject var searchService:LocationSearchService
    @Environment(\.presentationMode) var presentationMode
    
    @State var selectedLocation:MKMapItem
    @Binding var location:MKMapItem
    
    init(location locbind:Binding<MKMapItem>) {
        self._location = locbind
        self._selectedLocation = State(initialValue: locbind.wrappedValue)
    }
    
    var body:some View {
        
        VStack(alignment:.leading, spacing: 10.0) {
            //The "Toolbar"
            HStack {
                //Button("Update") { updateLocation() }
                Spacer()
                Button("Cancel") { close() }
            }
            Text("Pick a Location").font(.title)
            
            HStack(alignment: .firstTextBaseline) {
                Text("Location:")
                Spacer()
                Button(action: { updateLocation() }, label: {
                    VStack(alignment: .leading) {
                        Text(selectedLocation.name ?? "No name provided")
                        HStack {
                            Text("\(selectedLocation.placemark.coordinate.latitude)" )
                            Text("\(selectedLocation.placemark.coordinate.longitude)" )
                        }
                    }
                }).buttonStyle(.borderedProminent)
            }
            HStack {
                LocationSearchField()
                
            }.zIndex(10)
            //List(1..<5) { _ in
            List(searchService.resultItems, id:\.self) { item in
                HStack {
//                    Image(systemName: "globe").resizable()
//                        .aspectRatio(contentMode: .fit)
                    Button(action: {
                        updateSelected(item: item)
                        updateLocation()
                    },
                           label: { MapItemRow(item: item) }
                    ).buttonStyle(.bordered)
                        .layoutPriority(3)
                }
            }.listStyle(.plain)
        }.environmentObject(searchService)
            .padding(15)

    }
    
    func updateSelected(item:MKMapItem) {
        selectedLocation = item
    }
    
    func updateLocation() {
        location = selectedLocation
        close()
    }
    
    func close() {
        presentationMode.wrappedValue.dismiss()
    }
}


struct CurrentLocationButton: View {
    let locationRequester:()->()
    
    var body: some View {
        if #available(iOS 15.0, *) {
            LocationButton(.currentLocation) {
                locationRequester()
            }.symbolVariant(.fill)
                .labelStyle(.iconOnly)
                .foregroundColor(Color.white)
                .cornerRadius(20)
        }
    }
}



struct LocationPickerExample_Previews: PreviewProvider {
    static var previews: some View {
        LocationPickerExample()
    }
}



