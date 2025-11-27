//
//  ContentView.swift
//  WorkerApp
//
//  Created by Jordi Pereira Gil on 26/11/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    var body: some View {
        TabView {
            Tab("Requests", systemImage: "tray.and.arrow.down") {
                CarRequestList(requestType: "available")
            }

            Tab("Accepted requests", systemImage: "tray.and.arrow.up") {
                CarRequestList(requestType: "worker", workerId: 1)
            }
        }

    }
}

#Preview {
    ContentView()
}
