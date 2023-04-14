//
//  EnergiebilanzApp.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 24.03.23.
//

import SwiftUI

@main
struct EnergiebilanzApp: App {
            
    // https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app#Share-an-object-throughout-your-app
    @StateObject var viewModel = ContentViewModel()
    
    var body: some Scene {
        WindowGroup {
#if os(iOS)
            let currentDeviceModel = UIDevice.current.model
            if currentDeviceModel.starts(with: "iPad") {
                ContentView().environmentObject(viewModel)
                    .environment(\.locale, .init(identifier: "de"))
            }
            else {
                NavigationView {
                    ContentView()
                        .environmentObject(viewModel)
                        .navigationTitle(LocalizedStringKey("energiebilanz"))
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
//                                    print("Pressed")
                                    viewModel.fetchItems()
                                } label: {
                                    Label("refresh", systemImage: "arrow.clockwise.circle").foregroundColor(Color.gray)
                                }
                            }
                        }
                }
            }
#else
            ContentView().environmentObject(viewModel)
#endif
        }
    }
}
