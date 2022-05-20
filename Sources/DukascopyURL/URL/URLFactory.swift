//
//  DukascopyURLFactory.swift
//  Chart
//
//  Created by Vitali Kurlovich on 4/4/20.
//  Copyright © 2020 Vitali Kurlovich. All rights reserved.
//

import Foundation

/*
 https://datafeed.dukascopy.com/datafeed/ACFREUR/2020/03/05/BID_candles_min_1.bi5
 https://datafeed.dukascopy.com/datafeed/ACFREUR/2020/03/18/09h_ticks.bi5
 */

/*

 func infoRequest() -> URLRequest {
     let base = "https://freeserv.dukascopy.com/2.0/index.php?path=common%2Finstruments&json"
     let url = URL(string: base)!

     var request = URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)

     request.setValue("freeserv.dukascopy.com", forHTTPHeaderField: "Authority")
     request.setValue("https://freeserv.dukascopy.com/", forHTTPHeaderField: "Referer")

     return request
 }

 */

public
struct URLFactory {
    public typealias PriceType = DukascopyPriceType
    public typealias Format = DukascopyFormat

    public
    enum FactoryError: Error {
        case invalidCurrency
        case invalidMonth
        case invalidDay
        case invalidHour
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
extension URLFactory {
    @available(*, deprecated, message: "Use instruments")
    func infoURL() -> URL {
        instruments().url
    }
}

public
extension URLFactory {
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

extension URLFactory {
    func quotes(format: Format, for currency: String, date: Date) throws -> (url: URL, range: Range<Date>) {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return try quotes(format: format, for: currency, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!)
    }
}

public
extension URLFactory {
    func quotes(format: Format, for currency: String, range: Range<Date>) throws -> [(url: URL, range: Range<Date>)] {
        guard !currency.isEmpty else {
            throw FactoryError.invalidCurrency
        }

        let lowerComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.lowerBound)
        let upperComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.upperBound)

        guard let lower = calendar.date(from: lowerComps),
              let upper = calendar.date(from: upperComps)
        else {
            throw FactoryError.invalidDateRange
        }

        var urls = [(url: URL, range: Range<Date>)]()

        var current = lower

        switch format {
        case .ticks:
            let quotes = try quotes(format: format, for: currency, date: current)
            urls.append(quotes)

        case .candles:
            let quotes = try quotes(format: format, for: currency, date: current)
            urls.append(quotes)
        }

        switch format {
        case .ticks:
            let hour = DateComponents(hour: 1)
            while let next = calendar.date(byAdding: hour, to: current), next < upper {
                current = next

                let quotes = try quotes(format: format, for: currency, date: current)
                urls.append(quotes)
            }
        case .candles:
            let day = DateComponents(day: 1)
            while let next = calendar.date(byAdding: day, to: current), next < upper {
                current = next

                let quotes = try quotes(format: format, for: currency, date: current)
                urls.append(quotes)
            }
        }

        return urls
    }
}

private
extension URLFactory {
    func quotes(format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int = 0) throws -> (url: URL, range: Range<Date>) {
        guard (1 ... 12).contains(month) else {
            throw FactoryError.invalidMonth
        }

        guard (1 ... 31).contains(day) else {
            throw FactoryError.invalidDay
        }

        guard (0 ... 23).contains(hour) else {
            throw FactoryError.invalidHour
        }

        let currency = currency.uppercased()

        guard !currency.isEmpty else {
            throw FactoryError.invalidCurrency
        }

        var comps = DateComponents()
        comps.year = year
        comps.day = day
        comps.month = month

        let url: URL

        let lowerDate: Date
        let upperDate: Date

        switch format {
        case .ticks:
            let format = "\(baseUrl)/\(currency)/%d/%02d/%02d/%02dh_ticks.bi5"
            let baseUrl = String(format: format, year, month - 1, day, hour)
            url = URL(string: baseUrl)!

            comps.hour = hour

            lowerDate = calendar.date(from: comps)!

            let hour = DateComponents(hour: 1)
            upperDate = calendar.date(byAdding: hour, to: lowerDate)!

        case let .candles(type):
            let format: String
            switch type {
            case .ask:
                format = "\(baseUrl)/\(currency)/%d/%02d/%02d/ASK_candles_min_1.bi5"
            case .bid:
                format = "\(baseUrl)/\(currency)/%d/%02d/%02d/BID_candles_min_1.bi5"
            }

            let baseUrl = String(format: format, year, month - 1, day)
            url = URL(string: baseUrl)!

            lowerDate = calendar.date(from: comps)!

            let day = DateComponents(day: 1)
            upperDate = calendar.date(byAdding: day, to: lowerDate)!
        }

        return (url: url, range: lowerDate ..< upperDate)
    }
}

public extension URLFactory {
    @available(*, deprecated, message: "Use quotes")
    func url(format: Format, for currency: String, range: Range<Date>) throws -> [(url: URL, range: Range<Date>)] {
        return try quotes(format: format, for: currency, range: range)
    }

    @available(*, deprecated, message: "Use quotes")
    func url(format: Format, for currency: String, date: Date) throws -> URL {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return try url(format: format, for: currency, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!)
    }

    @available(*, deprecated, message: "Use quotes")
    func url(format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int = 0) throws -> URL {
        return try quotes(format: format, for: currency, year: year, month: month, day: day, hour: hour).url
    }
}

private let utc = TimeZone(identifier: "UTC")!

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc
    return calendar
}()
