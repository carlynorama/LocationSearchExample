//https://www.pointfree.co/episodes/ep156-searchable-swiftui-part-1

//import MapKit
//
//let completer = MKLocalSearchCompleter()
//let delegate = LocalSearchCompleterDelegate()
//completer.delegate = delegate
//
//completer.queryFragment = "New"
//
//completer.results
//
//class LocalSearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
//  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
//    print("succeeded")
//    dump(completer.results)
//  }
//
//  func completer(
//    _ completer: MKLocalSearchCompleter, didFailWithError error: Error
//  ) {
//    print("failed", error)
//  }
//}
