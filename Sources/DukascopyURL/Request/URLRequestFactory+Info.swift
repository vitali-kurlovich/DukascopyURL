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

private
extension URLRequest {
    mutating
    func setHeaders(with headers: [String: String]) {
        for (key, value) in headers {
            setValue(value, forHTTPHeaderField: key)
        }
    }
}

public
extension URLRequestFactory {
    func infoRequest(cachePolicy: URLRequest.CachePolicy, timeout: TimeInterval) -> URLRequest {
        let info = urlFactory.instruments()
        var request = URLRequest(url: info.url, cachePolicy: cachePolicy, timeoutInterval: timeout)

        request.setHeaders(with: info.headers)

        return request
    }

    func infoRequest(cachePolicy: URLRequest.CachePolicy) -> URLRequest {
        let info = urlFactory.instruments()

        var request = URLRequest(url: info.url, cachePolicy: cachePolicy)

        request.setHeaders(with: info.headers)

        return request
    }

    func infoRequest(timeout: TimeInterval) -> URLRequest {
        let info = urlFactory.instruments()
        var request = URLRequest(url: info.url, timeoutInterval: timeout)

        request.setHeaders(with: info.headers)

        return request
    }

    func infoRequest() -> URLRequest {
        let info = urlFactory.instruments()
        var request = URLRequest(url: info.url)

        request.setHeaders(with: info.headers)

        return request
    }
}
