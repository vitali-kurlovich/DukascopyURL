//
//  File.swift
//
//
//  Created by Vitali Kurlovich on 15.12.20.
//

import Foundation

public enum DukascopyPriceType {
    case ask
    case bid
}

public enum DukascopyFormat {
    case ticks
    case candles(DukascopyPriceType)
}
