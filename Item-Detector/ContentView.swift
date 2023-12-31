//
//  ContentView.swift
//  item-detector
//
//  Created by Jerry Li on 12/24/23.
//

import SwiftUI

struct ContentView: View {
    @State private var buttonClicked = false
    let myArray = ["Apple", "Banana", "Orange", "Apple", "Banana", "Orange", "Apple", "Banana", "Orange"] // test

    var body: some View {
        HostedViewController()
            .ignoresSafeArea()
        
        Button(action: {
            // Add your code here to handle button tap
            print("Button tapped!")
            buttonClicked.toggle()
        }) {
            Text(buttonClicked ? "Close" : "Detect Item")
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }
        if buttonClicked{
            List(myArray, id: \.self) { item in
                Text(item)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
