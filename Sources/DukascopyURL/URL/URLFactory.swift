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

public
struct URLFactory {
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
        case invalidCurrency
        case invalidMonth
        case invalidDay
        case invalidHour
        case invalidDateRange
    }

    private let baseUrl: String

    public
    init(_ baseUrl: String = "https://datafeed.dukascopy.com/datafeed") {
        self.baseUrl = baseUrl
    }
}

extension URLFactory {
    public
    func url(format: Format, for currency: String, range: Range<Date>) throws -> [(url: URL, range: Range<Date>)] {
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
            if let url = try? url(format: format, for: currency, date: current) {
                let hour = DateComponents(hour: 1)
                let next = calendar.date(byAdding: hour, to: current)!

                urls.append((url: url, range: current ..< next))
            }
        case .candles:

            if let url = try? url(format: format, for: currency, date: current) {
                let day = DateComponents(day: 1)
                let next = calendar.date(byAdding: day, to: current)!

                urls.append((url: url, range: current ..< next))
            }
        }

        switch format {
        case .ticks:
            let hour = DateComponents(hour: 1)
            while let next = calendar.date(byAdding: hour, to: current), next < upper {
                current = next

                if let url = try? url(format: format, for: currency, date: current) {
                    let hour = DateComponents(hour: 1)
                    let next = calendar.date(byAdding: hour, to: current)!
                    urls.append((url: url, range: current ..< next))
                }
            }
        case .candles:
            let day = DateComponents(day: 1)
            while let next = calendar.date(byAdding: day, to: current), next < upper {
                current = next

                if let url = try? url(format: format, for: currency, date: current) {
                    let next = calendar.date(byAdding: day, to: current)!
                    urls.append((url: url, range: current ..< next))
                }
            }
        }

        return urls
    }

    public
    func url(format: Format, for currency: String, date: Date) throws -> URL {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return try url(format: format, for: currency, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!)
    }

    public
    func url(format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int = 0) throws -> URL {
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

        switch format {
        case .ticks:
            let format = "\(baseUrl)/\(currency)/%d/%02d/%02d/%02dh_ticks.bi5"
            let baseUrl = String(format: format, year, month - 1, day, hour)
            return URL(string: baseUrl)!
        case let .candles(type):
            let format: String
            switch type {
            case .ask:
                format = "\(baseUrl)/\(currency)/%d/%02d/%02d/ASK_candles_min_1.bi5"
            case .bid:
                format = "\(baseUrl)/\(currency)/%d/%02d/%02d/BID_candles_min_1.bi5"
            }

            let baseUrl = String(format: format, year, month - 1, day)
            return URL(string: baseUrl)!
        }
    }
}

private let utc = TimeZone(identifier: "UTC")!

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc
    return calendar
}()
