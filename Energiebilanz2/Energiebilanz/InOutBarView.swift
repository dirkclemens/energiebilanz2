//
//  InOutBarView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 04.04.23.
//

import SwiftUI
import Charts

struct InOutBarView: View {
    /// @Binding wird normalerweise für die Übertragung von Daten zwischen verschiedenen Views innerhalb der SwiftUI-Hierarchie verwendet.
    @Binding var barMarkItems: [InOutBarChartModel]
    /// @StateObject verwendet, um komplexe Objekte zu verfolgen, die eine Lebensdauer haben, die über die des Views hinausgeht.
    /// Es wird normalerweise für Modellobjekte verwendet, die von mehreren Views oder anderen Objekten verwendet werden können.
    @StateObject var barMarkViewModel = InOutBarMarkViewModel()
//    @ObservedObject var barMarkViewModel = InOutBarMarkViewModel()
    
    var body: some View {

        Chart($barMarkItems, id: \.id) { $item in
            BarMark(
                x: .value("Energiebilanz", item.value)
            )
            .foregroundStyle(by: .value("Quelle", item.source))
            .annotation(position: .overlay, alignment: .center) {
                Text("\(item.value) W").font(.caption)
            }
            .cornerRadius(5)
        } // Chart
        .frame(height: 65)
        .frame(minHeight: 60, maxHeight: 70)
        .frame(idealWidth: 350)
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.gray.opacity(0.1))
                .cornerRadius(2)
        }
        .chartLegend(position: .bottom, alignment: .center)
        .chartForegroundStyleScale([
            "Erzeugung": .orange,
            "Netzbezug" : Constants.steelBlue,
            "Einspeisung": Constants.lemonYellow,
            "Verbrauch" : Constants.evccGreen]
        )
        .onTapGesture {
            // debug(".onTapGesture()")
//            reloadData()
        }
    }
}

