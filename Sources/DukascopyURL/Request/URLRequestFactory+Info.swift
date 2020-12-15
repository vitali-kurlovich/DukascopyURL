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
    func updateHeader() {
        setValue("freeserv.dukascopy.com", forHTTPHeaderField: "Authority")
        setValue("https://freeserv.dukascopy.com/", forHTTPHeaderField: "Referer")
    }
}

public
extension URLRequestFactory {
    func infoRequest(cachePolicy: URLRequest.CachePolicy, timeout: TimeInterval) -> URLRequest {
        var request = URLRequest(url: urlFactory.infoURL(), cachePolicy: cachePolicy, timeoutInterval: timeout)

        request.updateHeader()

        return request
    }

    func infoRequest(cachePolicy: URLRequest.CachePolicy) -> URLRequest {
        var request = URLRequest(url: urlFactory.infoURL(), cachePolicy: cachePolicy)

        request.updateHeader()

        return request
    }

    func infoRequest(timeout: TimeInterval) -> URLRequest {
        var request = URLRequest(url: urlFactory.infoURL(), timeoutInterval: timeout)

        request.updateHeader()

        return request
    }

    func infoRequest() -> URLRequest {
        var request = URLRequest(url: urlFactory.infoURL())

        request.updateHeader()

        return request
    }
}
