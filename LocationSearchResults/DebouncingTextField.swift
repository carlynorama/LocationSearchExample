//
//  DebouncingTextField.swift
//  LocationSearchResults
//
//  Created by Labtanza on 8/13/22.
// https://stackoverflow.com/questions/66164898/swiftui-combine-debounce-textfield
// https://stackoverflow.com/questions/62635914/initialize-stateobject-with-a-parameter-in-swiftui

import SwiftUI


class TextFieldObserver : ObservableObject {
    @Published var debouncedText = ""
    @Published var searchText = ""
        
    init(delay: DispatchQueue.SchedulerTimeType.Stride) {
        $searchText
            .debounce(for: delay, scheduler: DispatchQueue.main)
            .assign(to: &$debouncedText)
            //replaced this with the assign.
            //.sink(receiveValue: { [weak self] value in
            //    self?.debouncedText = value
            //})
            //.store(in: &cancellables) //-> private var cancellables = Set<AnyCancellable>()
    }
    
    public func overrideText(_ string:String) {
        searchText = string
    }
}


struct DebouncingTextField : View {
    var promptText:String = ""
    @Binding var debouncedText : String
    @StateObject private var textObserver:TextFieldObserver
    
    init(_ prompt:String, text binding:Binding<String>, debounceDelay:Double) {
        self.promptText = prompt
        self._debouncedText = binding
        //only okay because this stateobject is NOT a persistant ViewModel
        self._textObserver = StateObject(wrappedValue: TextFieldObserver(delay: DispatchQueue.SchedulerTimeType.Stride(floatLiteral: debounceDelay)))
    }
    
    var body: some View {
        TextField(promptText, text: $textObserver.searchText)
            .onReceive(textObserver.$debouncedText) { (val) in
                debouncedText = val
            }
    }
    
    public func overrideText(_ string:String) {
        textObserver.overrideText(string)
    }
}
