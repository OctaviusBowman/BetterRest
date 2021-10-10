//
//  ContentView.swift
//  BetterRest
//
//  Created by Octavius Bowman on 10/3/21.
//

import SwiftUI
import CoreML

struct horizontalText: View {
    var text: String
    var time: String
    
    var body: some View {
        HStack {
            Text(text).font(.headline)
            Text(time).font(.headline).foregroundColor(Color.red)
        }
    }
}

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var recommendedBedTime: String {
        calculateBedtime()
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("When do you want to wake up?").font(.headline)) {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                Section(header: Text("Desired amount of sleep").font(.headline)) {
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                }
                
                Section(header: Text("Daily coffee intake").font(.headline)) {
                    Picker(("\(coffeeAmount)"), selection: $coffeeAmount) {
                        ForEach(0...20, id:\.self) {
                            Text("\($0) cups of coffee")
                        }
                    }
                    // Stepper View
                    
                    /* Stepper(value: $coffeeAmount, in: 1...20) {
                     if (coffeeAmount == 1) {
                     Text("One cup")
                     } else {
                     Text("\(coffeeAmount) cups")
                     }
                     } */
                }
                horizontalText(text: "Your ideal bedtime is: ", time: "\(recommendedBedTime)")
            }
            .navigationBarTitle("Better Rest")
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    func calculateBedtime() -> String {
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        let hour = (components.hour ?? 0) * 60 * 60
        let minutes = (components.minute ?? 0) * 60
        do {
            let model = try SleepCalculator(configuration: MLModelConfiguration())
            let prediction = try
            model.prediction(wake: Double(hour + minutes), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            let sleepTime = wakeUp - prediction.actualSleep
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: sleepTime)
        } catch {
            return "Error"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
