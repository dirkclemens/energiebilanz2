//
//  ContentView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 24.03.23.
//
//  icon made with: https://www.appicon.co/#app-icon

import Foundation
import SwiftUI
import Charts

struct ContentView: View {

    // https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app#Share-an-object-throughout-your-app
    @EnvironmentObject var viewModel: ContentViewModel

    @State private var selectedTimeRange : ProfileSection = .ps_today
    
    private let cv_timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {

//        var item = viewModel.energyItems.last
//        List() {
        List(viewModel.energyItems, id: \.id) { item in

#if os(macOS)
                Section {
                    HStack() {
                        Text(LocalizedStringKey("energiebilanz")).bold()
                        Spacer()
                        Text("In der Meer")
                            .foregroundColor(.secondary)
                    }
                }
#endif
                
                //------------------------------------------------------------------------
                Section {
                    VStack(spacing: 5.0) {
                        HStack() {
                            Text(LocalizedStringKey("wechselrichter")).bold()
                            Spacer()
                        }
                        
                        Picker("", selection: $selectedTimeRange) {
                            ForEach(ProfileSection.allCases, id: \.self) { option in
                                Text(option.rawValue).font(.caption)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.bottom, 5)
                        
                        if (selectedTimeRange == .ps_today) {
                            TodayChartView()
                        }
                        if (selectedTimeRange == .ps_week) {
                            WeekChartView()
                        }
                        if (selectedTimeRange == .ps_month) {
                            MonthChartView()
                        }
                        if (selectedTimeRange == .ps_year) {
                            YearChartView()
                        }
                        if (selectedTimeRange == .ps_all) {
                            InOutLineView().environmentObject(viewModel)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                                    
                //------------------------------------------------------------------------
                Section() {
                    VStack(spacing: 0.0) {
                        HStack {
                            Text("IN").bold()
                            Spacer()
                            Text("OUT").bold()
                        }
                        Spacer()

                        InOutBarView().environmentObject(viewModel)
                    }
                } // Section
                .padding(.bottom, 5)
                                
                #if os(macOS)
                Divider().frame(height: 15)
                #endif
                
                //------------------------------------------------------------------------
                VStack () {
                    Group {
                        HStack(alignment: .center, spacing: 0) {
                            Text("IN").bold()
                            Spacer()
                            Text(String(format: "%\(0.1)f W", item.pvPower + item.gridInPower)).bold()
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Text(LocalizedStringKey("erzeugung"))
                            Spacer()
                            Text(String(format: "%\(0.1)f W", item.outputpower))
                                .foregroundColor(.secondary.opacity(0.2))
                            Spacer().frame(width: 10)
                            Text(String(format: "%\(0.1)f W", item.pvPower))
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Text(LocalizedStringKey("netzbezug"))
                            Spacer()
                            Text(String(format: "%\(0.01)f W", item.gridInPower))
                        }
                    } // Group

                    Divider().frame(height: 15)
                    
                    Group {
                            HStack(alignment: .center, spacing: 0) {
                                Text("OUT").bold()
                                Spacer()
                                Text(String(format: "%\(0.01)f W", item.homePower + item.chargePower + (item.gridOutPower * (-1)))).bold()
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Text(LocalizedStringKey("verbrauch"))
                                Spacer()
                                Text(String(format: "%\(0.01)f W", item.homePower))
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Text(LocalizedStringKey("ladepunkt"))
                                Spacer()
                                Text(String(format: "%\(0.01)f W", item.chargePower))
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Text(LocalizedStringKey("einspeisung"))
                                Spacer()
                                Text(String(format: "%\(0.01)f W", item.gridOutPower))
                            }
                    } // Group

                    Divider().frame(height: 15)
                    
                    Group {
                        Section(header: Text(LocalizedStringKey("wechselrichter")).bold()){
                            HStack(alignment: .center, spacing: 0) {
                                VStack() {
                                    HStack(){
                                        Text(LocalizedStringKey("heute"))
                                        Spacer()
                                        Text(String(format: "%\(0.01)f kW", item.energytoday))
                                    }
                                    HStack(){
                                        Text(LocalizedStringKey("Gesamt"))
                                        Spacer()
                                        Text(String(format: "%\(0.01)f kW", item.energytotal + 27459)) // + 27459
                                    }
                                }
                            }
                        } // Section
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } // Group
                    
                    Divider().frame(height: 15)
                    
                    Group {
                        Section(header: Text(LocalizedStringKey("zweirichtungszaehler")).bold()){
                            HStack(alignment: .center, spacing: 0) {
                                VStack() {
                                    HStack(){
                                        Text(LocalizedStringKey("bezug"))
                                        Spacer()
                                        Text(String(format: "%\(0.0)f kWh", item.Total_in))
                                    }
                                    HStack(){
                                        Text(LocalizedStringKey("abgabe"))
                                        Spacer()
                                        Text(String(format: "%\(0.0)f kWh", item.Total_out))
                                    }
                                    HStack(){
                                        Text(LocalizedStringKey("momentan"))
                                        Spacer()
                                        Text(String(format: "%\(0.1)f Wh", item.Power_curr))
                                    }
                                } // VStack
                            } // HStack
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } // Section
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        if (item.charging == "true"){
                            Divider().frame(height: 15)
                            
                            Section(header: Link(LocalizedStringKey("ladestation"), destination: URL(string: Constants.evccLink)!).bold()){
                                HStack(alignment: .center, spacing: 0) {
                                    ZStack() {
                                        VStack() {
                                            HStack(){
                                                Text(LocalizedStringKey("Reichweite"))
                                                Spacer()
                                                Text(String(format: "%\(0.0)f km", item.vehicleRange))
                                            }
                                            HStack(){
                                                Text(LocalizedStringKey("Ladung"))
                                                Spacer()
                                                Text(String(format: "%\(0.0)f %%", item.vehicleSoc))
                                            }
                                            HStack(){
                                                Text(LocalizedStringKey("Laufleistung"))
                                                Spacer()
                                                Text(String(format: "%\(0.0)f km", item.vehicleOdometer))
                                            }
                                        } // VStack
                                    } // ZStack
                                    .overlay(Image("i3"), alignment: .bottom)
                                } // HStack
                            } // Section
                            .frame(maxWidth: .infinity, alignment: .leading)
                        } // isCharging
                    } // Group
                    
                } // VStack

                Spacer()

                //------------------------------------------------------------------------
                Section(){
                    HStack() {
                        Text("made with ").font(.caption).foregroundColor(Color.gray.opacity(0.5))
                        Image(systemName: "apple.logo").foregroundColor(Color.gray.opacity(0.5))
                        Text(" by dirk c.").font(.caption).foregroundColor(Color.gray.opacity(0.5))
                        Spacer()
                        Text(" version: \(version())").font(.caption).foregroundColor(Color.gray.opacity(0.5))
                    } // HStack
                } // Section
                .frame(maxWidth: .infinity, alignment: .bottomLeading)

            } // List
            .onAppear(){
                // debug(".onAppear()")
                viewModel.fetchItems()
            }
            .onReceive(cv_timer) { _ in
                // debug(".onReceive(timer) ==========================================")
                viewModel.fetchItems()
            }
            .refreshable { // pull to refresh
//                 debug("pull to refresh   ==========================================")
                viewModel.fetchItems()
            }
    } // View
}
