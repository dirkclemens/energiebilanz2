//
//  Common.swift
//  Energiebilanz
//
//  Created by Dirk Clemens on 27.03.23.
//

import Foundation
import SwiftUI

/*
    print log messages to stdout
 */
func debug(_ text: String) {
//    #if DEBUG
//    print("[\(Date(), formatter: Formatter.mediumTime)] \(text)")
//    #endif
}

/*
    print build version and date
    https://developer.apple.com/library/archive/qa/qa1827/_index.html
 */
func version() -> String {
    let dictionary = Bundle.main.infoDictionary!
    let version = dictionary["CFBundleShortVersionString"] as! String
    let build = dictionary["CFBundleVersion"] as! String
    return "\(version) build \(build)"
}

/*
    https://github.com/matteom/HackerNews/blob/master/HackerNews/Formatting.swift
 */
extension Int {
    var formatted: String {
        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
extension Double {
    var formatted: String {
        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    var noDecimals: String {
        let formatter = NumberFormatter()
//        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

/*
    calculation view dimensions when resizing a view
    https://stackoverflow.com/a/59733037/10590793
 */
struct GeometryGetter: View {
    @Binding var rect: CGRect
    @Binding var width: Double

    var body: some View {
        GeometryReader { (g) -> Path in
//            print("width: \(g.size.width), height: \(g.size.height)")
            DispatchQueue.main.async { // avoids warning: 'Modifying state during view update.' Doesn't look very reliable, but works.
                self.rect = g.frame(in: .global)
                self.width  = g.size.width
            }
            return Path() // could be some other dummy view
        }
    }
}


/*
    convert String to Date
 */
func stringToDate(dt: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format // "yyyy-MM-dd HH:mm:ss"
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.locale = Locale.current
    return dateFormatter.date(from: dt) // replace Date String
}


/*
    https://www.ralfebert.de/ios/swift-dateformatter-datumsangaben-formatieren/
 */
extension DefaultStringInterpolation {
    mutating func appendInterpolation(_ value: Date, formatter: DateFormatter) {
        self.appendInterpolation(formatter.string(from: value))
    }
}
struct Formatter {

    /// 12:34
    static let mediumTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter
    }()

    /// 12.03.2021
    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    /// 12.03.2021 12:34
    static let mediumDateAndTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

}
