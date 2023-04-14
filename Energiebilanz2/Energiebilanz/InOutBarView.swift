//
//  InOutBarView.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 04.04.23.
//

import SwiftUI
import Charts

struct InOutBarView: View {

    // https://developer.apple.com/documentation/swiftui/managing-model-data-in-your-app#Share-an-object-throughout-your-app
    @EnvironmentObject var viewModel: ContentViewModel
    
    let barHeight: Double = 60.0
        
    var body: some View {

        Chart {
            let inOutItem = viewModel.ioDataItems.last
            ForEach(inOutItem!.inOutItems, id: \.id) { item in
                BarMark(
                    x: .value("Energiebilanz", item.value)
                )
                .foregroundStyle(by: .value("Quelle", item.source))
                .annotation(position: .overlay, alignment: .center) {
                    Text("\(item.value.noDecimals) W").font(.caption)
                }
                .cornerRadius(5)
            }            
        }
        .frame(height: barHeight + 5)
        .frame(minHeight: barHeight, maxHeight: barHeight + 10)
        .frame(idealWidth: 350)
        .chartPlotStyle { plotArea in
            plotArea
                .background(Color.gray.opacity(0.1))
                .cornerRadius(2)
        }
        .chartLegend(position: .bottom, alignment: .center)
        .chartForegroundStyleScale([
            Constants.sourceErzeugung: .orange,
            Constants.sourceNetzbezug: Constants.steelBlue,
            Constants.sourceEinspeisung: Constants.lemonYellow,
            Constants.sourceVerbrauch: Constants.evccGreen,
            Constants.sourceLadepunkt: Constants.aubergine]
        )
        .onTapGesture {
            // debug(".onTapGesture()")
            viewModel.fetchItems()
        }
    }
}

