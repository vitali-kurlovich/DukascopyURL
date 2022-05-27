//
//  Created by Vitali Kurlovich on 4/4/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import Foundation

/*
 https://datafeed.dukascopy.com/datafeed/ACFREUR/2020/03/05/BID_candles_min_1.bi5
 https://datafeed.dukascopy.com/datafeed/ACFREUR/2020/03/18/09h_ticks.bi5
 */

public
struct DukascopyRemoteURL {
    public enum PriceType {
        case ask
        case bid
    }

    public enum Format {
        case ticks
        case candles(PriceType)
    }

    public
    enum FactoryError: Error {
        case invalidDateRange
    }

    private let baseUrl: String
    private let infoUrl: String

    public
    init(_ baseUrl: String = "https://datafeed.dukascopy.com/datafeed", infoUrl: String = "https://freeserv.dukascopy.com/2.0") {
        self.baseUrl = baseUrl
        self.infoUrl = infoUrl
    }
}

public
extension DukascopyRemoteURL {
    func instruments() -> (url: URL, headers: [String: String]) {
        let string = infoUrl + "/index.php?path=common%2Finstruments&json"
        let url = URL(string: string)!

        let headers = [
            "Authority": "freeserv.dukascopy.com",
            "Referer": "https://freeserv.dukascopy.com/",
        ]
        return (url: url, headers: headers)
    }
}

public
extension DukascopyRemoteURL {
    func quotes(format: Format, for filename: String, date: Date) -> (url: URL, range: Range<Date>, file: String, dir: String) {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return quotes(format: format, for: filename, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!)
    }
}

public
extension DukascopyRemoteURL {
    func quotes(format: Format, for filename: String, range: Range<Date>) -> [(url: URL, range: Range<Date>, file: String, dir: String)] {
        precondition(!filename.isEmpty, "currency can't be empty")

        let lowerComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.lowerBound)
        let upperComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.upperBound)

        let lower = calendar.date(from: lowerComps)!
        let upper = calendar.date(from: upperComps)!

        var urls = [(url: URL, range: Range<Date>, file: String, dir: String)]()

        var current = lower

        switch format {
        case .ticks:
            let quotes = quotes(format: format, for: filename, date: current)
            urls.append(quotes)

        case .candles:
            let quotes = quotes(format: format, for: filename, date: current)
            urls.append(quotes)
        }

        switch format {
        case .ticks:
            let hour = DateComponents(hour: 1)
            while let next = calendar.date(byAdding: hour, to: current), next < upper {
                current = next

                let quotes = quotes(format: format, for: filename, date: current)
                urls.append(quotes)
            }
        case .candles:
            let day = DateComponents(day: 1)
            while let next = calendar.date(byAdding: day, to: current), next < upper {
                current = next

                let quotes = quotes(format: format, for: filename, date: current)
                urls.append(quotes)
            }
        }

        return urls
    }
}

private
extension DukascopyRemoteURL {
    func quotes(format: Format, for filename: String, year: Int, month: Int, day: Int, hour: Int = 0) -> (url: URL, range: Range<Date>, file: String, dir: String) {
        let filename = filename.uppercased()

        var comps = DateComponents()
        comps.year = year
        comps.day = day
        comps.month = month

        let lowerDate: Date
        let upperDate: Date

        let file_name: String

        let file_dir = String(format: "\(filename)/%d/%02d/%02d/", year, month - 1, day)

        switch format {
        case .ticks:

            file_name = String(format: "%02dh_ticks.bi5", hour)

            comps.hour = hour

            lowerDate = calendar.date(from: comps)!

            let hour = DateComponents(hour: 1)
            upperDate = calendar.date(byAdding: hour, to: lowerDate)!

        case let .candles(type):

            switch type {
            case .ask:
                file_name = "ASK_candles_min_1.bi5"

            case .bid:
                file_name = "BID_candles_min_1.bi5"
            }

            lowerDate = calendar.date(from: comps)!

            let day = DateComponents(day: 1)
            upperDate = calendar.date(byAdding: day, to: lowerDate)!
        }

        let baseUrl = "\(baseUrl)/\(file_dir)\(file_name)"
        let url = URL(string: baseUrl)!

        return (url: url, range: lowerDate ..< upperDate, file: file_name, dir: file_dir)
    }
}

private let utc = TimeZone(identifier: "UTC")!

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc
    return calendar
}()
