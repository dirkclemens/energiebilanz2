//
//  EnergiebilanzApp.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 24.03.23.
//

import SwiftUI

@main
struct EnergiebilanzApp: App {
            
    var body: some Scene {                
        WindowGroup {
#if os(iOS)
            let currentDeviceModel = UIDevice.current.model
            if currentDeviceModel.starts(with: "iPad") {
                ContentView()
            }
            else {
                NavigationView {
                    ContentView()
                        .navigationTitle("Energiebilanz")
                        .navigationBarTitleDisplayMode(.automatic)
                        .toolbar {
                            ToolbarItemGroup() {
                                Spacer()
                                Button {
                                } label: {
                                    Link(destination: URL(string: Constants.evccLink)!, label: {
                                        Label("evcc", systemImage: "bolt.circle").foregroundColor(Color.gray)
                                    })
                                }
                                Button {
                                    print("Pressed")
//                                    reloadData()
//                                    _ = viewModel.fetchItems()
                                } label: {
                                    Label("refresh", systemImage: "arrow.clockwise.circle").foregroundColor(Color.gray)
                                }
                            }
                        }
                }
            }
#else
            ContentView()
#endif
        }
    }
}
