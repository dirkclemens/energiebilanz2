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

    @EnvironmentObject var contentViewModel: ContentViewModel // Access the shared ContentViewModel

    /// @StateObject verwendet, um komplexe Objekte zu verfolgen, die eine Lebensdauer haben, die über die des Views hinausgeht.
    /// Es wird normalerweise für Modellobjekte verwendet, die von mehreren Views oder anderen Objekten verwendet werden können.
    @StateObject var viewModel = ContentViewModel()
    @StateObject var lineMarkViewModel = LineMarkViewModel()
    @StateObject var barMarkViewModel = InOutBarMarkViewModel()

    /// @State ist ein Property Wrapper, mit dem der Zustand von Views verfolgt wird.
    @State var selectedTimeRange : ProfileSection = .ps_today
    
    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {

            List(viewModel.energyItems, id: \.id) { item in

#if os(macOS)
                Section {
                    HStack() {
                        Text("Energiebilanz").bold()
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
                            Text("Wechselrichter").bold()
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
                            InOutLineView(lineMarkItems: $lineMarkViewModel.lineMarkItems)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                                    
                //------------------------------------------------------------------------
                Section() {
                    VStack(spacing: 0.0) {
                        HStack {
                            Text("IN").bold()
//                                .foregroundColor(.secondary)
                            Spacer()
                            Text("OUT").bold()
//                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        
//                        InOutBarView(barMarkViewModel = viewModel.fetchItems())
                        InOutBarView(barMarkItems: $barMarkViewModel.barMarkItems)
//                        myInOutChartView
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
                            Text("Erzeugung (PV):")
                            Spacer()
                            Text(String(format: "%\(0.1)f W", item.outputpower))
                                .foregroundColor(.secondary.opacity(0.2))
                            Spacer().frame(width: 10)
                            Text(String(format: "%\(0.1)f W", item.pvPower))
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Text("Netzbezug:")
                            Spacer()
                            Text(String(format: "%\(0.01)f W", item.gridInPower))
                        }
                    } // Group
                    .onTapGesture {
                        reloadData()
//                        viewModel.fetchItems()
                    }

                    Divider().frame(height: 15)
                    
                    Group {
                            HStack(alignment: .center, spacing: 0) {
                                Text("OUT").bold()
                                Spacer()
                                Text(String(format: "%\(0.01)f W", item.homePower + item.chargePower + (item.gridOutPower * (-1)))).bold()
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Text("Verbrauch:")
                                Spacer()
                                Text(String(format: "%\(0.01)f W", item.homePower))
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Text("Ladepunkt:")
                                Spacer()
                                Text(String(format: "%\(0.01)f W", item.chargePower))
                            }
                            HStack(alignment: .center, spacing: 0) {
                                Text("Einspeisung:")
                                Spacer()
                                Text(String(format: "%\(0.01)f W", item.gridOutPower))
                            }
                    } // Group
                    .onTapGesture {
                        reloadData()
//                        viewModel.fetchItems()
                    }

                    Divider().frame(height: 15)
                    
                    Group {
                        Section(header: Text("Wechselrichter").bold()){
                            HStack(alignment: .center, spacing: 0) {
                                VStack() {
                                    HStack(){
                                        Text("heute")
                                        Spacer()
                                        Text(String(format: "%\(0.01)f kW", item.energytoday))
                                    }
                                    HStack(){
                                        Text("Gesamt")
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
                        Section(header: Text("Zweirichtungszähler").bold()){
                            HStack(alignment: .center, spacing: 0) {
                                VStack() {
                                    HStack(){
                                        Text("Bezug (1.8.0)")
                                        Spacer()
                                        Text(String(format: "%\(0.0)f kWh", item.Total_in))
                                    }
                                    HStack(){
                                        Text("Abgabe (2.8.0)")
                                        Spacer()
                                        Text(String(format: "%\(0.0)f kWh", item.Total_out))
                                    }
                                    HStack(){
                                        Text("Momentan (1.6.7)")
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
                            
                            Section(header: Link("Ladestation", destination: URL(string: Constants.evccLink)!).bold()){
                                HStack(alignment: .center, spacing: 0) {
                                    ZStack() {
                                        VStack() {
                                            HStack(){
                                                Text("Reichweite")
                                                Spacer()
                                                Text(String(format: "%\(0.0)f km", item.vehicleRange))
                                            }
                                            HStack(){
                                                Text("Ladung")
                                                Spacer()
                                                Text(String(format: "%\(0.0)f %%", item.vehicleSoc))
                                            }
                                            HStack(){
                                                Text("Laufleistung")
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
            } // List
            .onAppear(){
                // debug(".onAppear()")
                reloadData()
//                viewModel.fetchItems()
            }
            .onReceive(timer) { _ in
                // debug(".onReceive(timer) ==========================================")
                reloadData()
//                viewModel.fetchItems()
            }
            .refreshable { // pull to refresh
//                 debug("pull to refresh   ==========================================")
                reloadData()
//                viewModel.fetchItems()
            }
    } // View
}

extension ContentView {
    
    func reloadData() {
//         debug("viewModel.fetchItems() ===================================================")
        // read json from server
        _ = viewModel.fetchItems()
        
//        debug("reloadData()->amount: \(amount)")
        debug("reloadData()->viewModel.items.count: \(viewModel.energyItems.count)")
        if (viewModel.energyItems.count > 0) {
            
            /*
             barMark
             */
            let newItems: [InOutBarChartModel] = [
                InOutBarChartModel(id: 0, source: "Erzeugung", value: Int(viewModel.energyItems.first!.pvPower * (-1))),
                InOutBarChartModel(id: 1, source: "Netzbezug", value: Int(viewModel.energyItems.first!.gridInPower * (-1))),
                InOutBarChartModel(id: 2, source: "Einspeisung", value: Int(viewModel.energyItems.first!.gridOutPower * (-1))),
                InOutBarChartModel(id: 3, source: "Verbrauch", value: Int(viewModel.energyItems.first!.homePower))
            ]
            // update / replace old data, do not append !
            barMarkViewModel.update(newItems)
            
            
            /*
            lineMark & pointMark
             */
            let additionalItems: [LineMarkDataModel] = [
                LineMarkDataModel(source: "Erzeugung", value: viewModel.energyItems.first!.pvPower * (-1)),
                LineMarkDataModel(source: "Netzbezug", value: viewModel.energyItems.first!.gridInPower * (-1)),
                LineMarkDataModel(source: "Einspeisung", value: viewModel.energyItems.first!.gridOutPower * (-1)),
                LineMarkDataModel(source: "Verbrauch", value: viewModel.energyItems.first!.homePower)
            ]
            // append data for LineMark Chart
            lineMarkViewModel.append(additionalItems)
        }
    }
}

