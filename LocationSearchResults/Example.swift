//
//  Address.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/13/22.
//

//https://stackoverflow.com/questions/70571615/swiftui-using-mapkit-for-address-auto-complete
//https://stackoverflow.com/questions/33380711/how-to-implement-auto-complete-for-address-using-apple-map-kit/67131376#67131376
//https://www.peteralt.com/blog/mapkit-location-search-with-swiftui/

import SwiftUI
import Combine
import MapKit
import CoreLocation

class MapSearch : NSObject, ObservableObject {
    @Published var locationResults : [MKLocalSearchCompletion] = []
    @Published var searchTerm = ""

    private var cancellables : Set<AnyCancellable> = []

    private var searchCompleter = MKLocalSearchCompleter()
    private var currentPromise : ((Result<[MKLocalSearchCompletion], Error>) -> Void)?

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = MKLocalSearchCompleter.ResultType([.address])

        $searchTerm
            .debounce(for: .seconds(0.2), scheduler: RunLoop.main)
            .removeDuplicates()
            .flatMap({ (currentSearchTerm) in
                self.searchTermToResults(searchTerm: currentSearchTerm)
            })
            .sink(receiveCompletion: { (completion) in
                //handle error
            }, receiveValue: { (results) in
                self.locationResults = results.filter { $0.subtitle.contains("United States") } // This parses the subtitle to show only results that have United States as the country. You could change this text to be Germany or Brazil and only show results from those countries.
            })
            .store(in: &cancellables)
    }

    func searchTermToResults(searchTerm: String) -> Future<[MKLocalSearchCompletion], Error> {
        Future { promise in
            self.searchCompleter.queryFragment = searchTerm
            self.currentPromise = promise
        }
    }
}

extension MapSearch : MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
            currentPromise?(.success(completer.results))
        }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        //could deal with the error here, but beware that it will finish the Combine publisher stream
        //currentPromise?(.failure(error))
    }
}

struct AlternateView: View {
    @StateObject private var mapSearch = MapSearch()

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Address", text: $mapSearch.searchTerm)
                }
                Section {
                    ForEach(mapSearch.locationResults, id: \.self) { location in
                        NavigationLink(destination: Detail(locationResult: location)) {
                            VStack(alignment: .leading) {
                                Text(location.title)
                                Text(location.subtitle)
                                    .font(.system(.caption))
                            }
                        }
                    }
                }
            }.navigationTitle(Text("Address search"))
        }
    }
}

class DetailViewModel : ObservableObject {
    @Published var isLoading = true
    @Published private var coordinate : CLLocationCoordinate2D?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion()

    var coordinateForMap : CLLocationCoordinate2D {
        coordinate ?? CLLocationCoordinate2D()
    }

    func reconcileLocation(location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                self.coordinate = coordinate
                self.region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
                self.isLoading = false
            }
        }
    }

    func clear() {
        isLoading = true
    }
}

struct Detail : View {
    var locationResult : MKLocalSearchCompletion
    @StateObject private var viewModel = DetailViewModel()

    struct Marker: Identifiable {
        let id = UUID()
        var location: MapMarker
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                Text("Loading...")
            } else {
                Map(coordinateRegion: $viewModel.region,
                    annotationItems: [Marker(location: MapMarker(coordinate: viewModel.coordinateForMap))]) { (marker) in
                    marker.location
                }
            }
        }.onAppear {
            viewModel.reconcileLocation(location: locationResult)
        }.onDisappear {
            viewModel.clear()
        }
        .navigationTitle(Text(locationResult.title))
    }
}

//struct AlternateView_Previews: PreviewProvider {
//    static var previews: some View {
//        AlternateView()
//    }
//}



//
//struct ReversedGeoLocation {
//    let streetNumber: String    // eg. 1
//    let streetName: String      // eg. Infinite Loop
//    let city: String            // eg. Cupertino
//    let state: String           // eg. CA
//    let zipCode: String         // eg. 95014
//    let country: String         // eg. United States
//    let isoCountryCode: String  // eg. US
//
//    var formattedAddress: String {
//        return """
//        \(streetNumber) \(streetName),
//        \(city), \(state) \(zipCode)
//        \(country)
//        """
//    }
//
//    // Handle optionals as needed
//    init(with placemark: CLPlacemark) {
//        self.streetName     = placemark.thoroughfare ?? ""
//        self.streetNumber   = placemark.subThoroughfare ?? ""
//        self.city           = placemark.locality ?? ""
//        self.state          = placemark.administrativeArea ?? ""
//        self.zipCode        = placemark.postalCode ?? ""
//        self.country        = placemark.country ?? ""
//        self.isoCountryCode = placemark.isoCountryCode ?? ""
//    }
//}
//
//
//struct Test: View {
//    @StateObject private var mapSearch = MapSearch()
//
//    func reverseGeo(location: MKLocalSearchCompletion) {
//        let searchRequest = MKLocalSearch.Request(completion: location)
//        let search = MKLocalSearch(request: searchRequest)
//        var coordinateK : CLLocationCoordinate2D?
//        search.start { (response, error) in
//        if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
//            coordinateK = coordinate
//        }
//
//        if let c = coordinateK {
//            let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
//            CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//
//            guard let placemark = placemarks?.first else {
//                let errorString = error?.localizedDescription ?? "Unexpected Error"
//                print("Unable to reverse geocode the given location. Error: \(errorString)")
//                return
//            }
//
//            let reversedGeoLocation = ReversedGeoLocation(with: placemark)
//
//            address = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName)"
//            city = "\(reversedGeoLocation.city)"
//            state = "\(reversedGeoLocation.state)"
//            zip = "\(reversedGeoLocation.zipCode)"
//            mapSearch.searchTerm = address
//            isFocused = false
//
//                }
//            }
//        }
//    }
//
//    // Form Variables
//
//    @FocusState private var isFocused: Bool
//
//    @State private var btnHover = false
//    @State private var isBtnActive = false
//
//    @State private var address = ""
//    @State private var city = ""
//    @State private var state = ""
//    @State private var zip = ""
//
//// Main UI
//
//    var body: some View {
//
//            VStack {
//                List {
//                    Section {
//                        Text("Start typing your street address and you will see a list of possible matches.")
//                    } // End Section
//
//                    Section {
//                        TextField("Address", text: $mapSearch.searchTerm)
//
//// Show auto-complete results
//                        if address != mapSearch.searchTerm && isFocused == false {
//                        ForEach(mapSearch.locationResults, id: \.self) { location in
//                            Button {
//                                reverseGeo(location: location)
//                            } label: {
//                                VStack(alignment: .leading) {
//                                    Text(location.title)
//                                        .foregroundColor(Color.white)
//                                    Text(location.subtitle)
//                                        .font(.system(.caption))
//                                        .foregroundColor(Color.white)
//                                }
//                        } // End Label
//                        } // End ForEach
//                        } // End if
//// End show auto-complete results
//
//                        TextField("City", text: $city)
//                        TextField("State", text: $state)
//                        TextField("Zip", text: $zip)
//
//                    } // End Section
//                    .listRowSeparator(.visible)
//
//            } // End List
//
//            } // End Main VStack
//
//    } // End Var Body
//
//} // End Struct
//
//struct Test_Previews: PreviewProvider {
//    static var previews: some View {
//        Test()
//    }
//}
