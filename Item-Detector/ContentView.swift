//
//  ContentView.swift
//  item-detector
//
//  Created by Jerry Li on 12/24/23.
//

import SwiftUI

struct ContentView: View {
    @State private var buttonClicked = false

    var body: some View {
        HostedViewController()
            .ignoresSafeArea()
        
        Button(action: {
            // Add your code here to handle button tap
            print("Button tapped!")
            buttonClicked.toggle()
        }) {
            Text("Detect Item")
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }
        if buttonClicked{
            Text("Opening Camera")
                .padding()
                .foregroundColor(.green)
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
