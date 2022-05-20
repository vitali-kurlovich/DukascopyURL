//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 15.12.20.
//

import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

@available(*, deprecated, message: "Use URLFactory") public
struct URLRequestFactory {
    public let urlFactory: URLFactory

    public typealias PriceType = DukascopyPriceType
    public typealias Format = DukascopyFormat

    public
    init(urlFactory: URLFactory = URLFactory()) {
        self.urlFactory = urlFactory
    }
}

public
extension URLRequestFactory {
    func request(cachePolicy: URLRequest.CachePolicy, timeout: TimeInterval, format: Format, for currency: String, range: Range<Date>) throws -> [(request: URLRequest, range: Range<Date>)] {
        let urls = try urlFactory.url(format: format, for: currency, range: range)

        return urls.compactMap { data -> (request: URLRequest, range: Range<Date>)? in
            let request = URLRequest(url: data.url, cachePolicy: cachePolicy, timeoutInterval: timeout)
            return (request: request, range: data.range)
        }
    }

    func request(cachePolicy: URLRequest.CachePolicy, format: Format, for currency: String, range: Range<Date>) throws -> [(request: URLRequest, range: Range<Date>)] {
        let urls = try urlFactory.url(format: format, for: currency, range: range)

        return urls.compactMap { data -> (request: URLRequest, range: Range<Date>)? in
            let request = URLRequest(url: data.url, cachePolicy: cachePolicy)
            return (request: request, range: data.range)
        }
    }

    func request(timeout: TimeInterval, format: Format, for currency: String, range: Range<Date>) throws -> [(request: URLRequest, range: Range<Date>)] {
        let urls = try urlFactory.url(format: format, for: currency, range: range)

        return urls.compactMap { data -> (request: URLRequest, range: Range<Date>)? in
            let request = URLRequest(url: data.url, timeoutInterval: timeout)
            return (request: request, range: data.range)
        }
    }

    func request(format: Format, for currency: String, range: Range<Date>) throws -> [(request: URLRequest, range: Range<Date>)] {
        let urls = try urlFactory.url(format: format, for: currency, range: range)

        return urls.compactMap { data -> (request: URLRequest, range: Range<Date>)? in
            let request = URLRequest(url: data.url)
            return (request: request, range: data.range)
        }
    }
}

public
extension URLRequestFactory {
    func request(cachePolicy: URLRequest.CachePolicy, timeout: TimeInterval, format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int) throws -> URLRequest {
        let url = try urlFactory.url(format: format, for: currency, year: year, month: month, day: day, hour: hour)

        return URLRequest(url: url, cachePolicy: cachePolicy, timeoutInterval: timeout)
    }

    func request(cachePolicy: URLRequest.CachePolicy, format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int) throws -> URLRequest {
        let url = try urlFactory.url(format: format, for: currency, year: year, month: month, day: day, hour: hour)

        return URLRequest(url: url, cachePolicy: cachePolicy)
    }

    func request(timeout: TimeInterval, format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int) throws -> URLRequest {
        let url = try urlFactory.url(format: format, for: currency, year: year, month: month, day: day, hour: hour)

        return URLRequest(url: url, timeoutInterval: timeout)
    }

    func request(format: Format, for currency: String, year: Int, month: Int, day: Int, hour: Int) throws -> URLRequest {
        let url = try urlFactory.url(format: format, for: currency, year: year, month: month, day: day, hour: hour)

        return URLRequest(url: url)
    }
}
