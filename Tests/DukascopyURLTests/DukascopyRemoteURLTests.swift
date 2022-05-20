//
//  Created by Vitali Kurlovich on 4/4/20.
//

@testable import DukascopyURL
import XCTest

private let utc = TimeZone(identifier: "UTC")!

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = utc
    return calendar
}()

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.timeZone = utc
    formatter.dateFormat = "dd-MM-yyyy HH:mm"
    return formatter
}()

final class DukascopyRemoteURLTests: XCTestCase {
    func testURLFactory() {
        let factory = DukascopyRemoteURL()

        let date = formatter.date(from: "02-04-2019 11:00")!
        let url = factory.quotes(format: .ticks, for: "EURUSD", date: date).url

        XCTAssertTrue(url.absoluteString.hasSuffix("EURUSD/2019/03/02/11h_ticks.bi5"))

        let end = formatter.date(from: "02-04-2019 14:00")!

        let quotes = factory.quotes(format: .ticks, for: "EURUSD", range: date ..< end)

        XCTAssertEqual(quotes.count, 3)

        XCTAssertTrue(quotes[0].url.absoluteString.hasSuffix("EURUSD/2019/03/02/11h_ticks.bi5"))
        XCTAssertEqual(quotes[0].range, formatter.date(from: "02-04-2019 11:00")! ..< formatter.date(from: "02-04-2019 12:00")!)

        XCTAssertTrue(quotes[1].url.absoluteString.hasSuffix("EURUSD/2019/03/02/12h_ticks.bi5"))
        XCTAssertEqual(quotes[1].range, formatter.date(from: "02-04-2019 12:00")! ..< formatter.date(from: "02-04-2019 13:00")!)

        XCTAssertTrue(quotes[2].url.absoluteString.hasSuffix("EURUSD/2019/03/02/13h_ticks.bi5"))
        XCTAssertEqual(quotes[2].range, formatter.date(from: "02-04-2019 13:00")! ..< formatter.date(from: "02-04-2019 14:00")!)
    }

    func testURLFactoryCandles() {
        let factory = DukascopyRemoteURL()

        let date = formatter.date(from: "02-04-2019 11:00")!
        let url = factory.quotes(format: .candles(.bid), for: "EURUSD", date: date).url

        XCTAssertTrue(url.absoluteString.hasSuffix("EURUSD/2019/03/02/BID_candles_min_1.bi5"))

        let end = formatter.date(from: "04-04-2019 19:00")!

        let quotes = factory.quotes(format: .candles(.ask), for: "EURUSD", range: date ..< end)

        XCTAssertEqual(quotes.count, 3)

        XCTAssertTrue(quotes[0].url.absoluteString.hasSuffix("EURUSD/2019/03/02/ASK_candles_min_1.bi5"))

        XCTAssertTrue(quotes[1].url.absoluteString.hasSuffix("EURUSD/2019/03/03/ASK_candles_min_1.bi5"))

        XCTAssertTrue(quotes[2].url.absoluteString.hasSuffix("EURUSD/2019/03/04/ASK_candles_min_1.bi5"))
    }

    func testURLFactoryInfo() {
        let factory = DukascopyRemoteURL()
        let headers = factory.instruments().headers

        XCTAssertNotNil(headers["Authority"])
        XCTAssertNotNil(headers["Referer"])
    }
}
