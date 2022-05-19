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

final class FactoryTests: XCTestCase {
    func testURLFactory() {
        let factory = URLFactory()

        let date = formatter.date(from: "02-04-2019 11:00")!
        let url = try! factory.url(format: .ticks, for: "EURUSD", date: date)

        XCTAssertTrue(url.absoluteString.hasSuffix("EURUSD/2019/03/02/11h_ticks.bi5"))

        let end = formatter.date(from: "02-04-2019 14:00")!

        let urls = try! factory.url(format: .ticks, for: "EURUSD", range: date ..< end)

        XCTAssertEqual(urls.count, 3)

        XCTAssertTrue(urls[0].url.absoluteString.hasSuffix("EURUSD/2019/03/02/11h_ticks.bi5"))
        XCTAssertEqual(urls[0].range, formatter.date(from: "02-04-2019 11:00")! ..< formatter.date(from: "02-04-2019 12:00")!)

        XCTAssertTrue(urls[1].url.absoluteString.hasSuffix("EURUSD/2019/03/02/12h_ticks.bi5"))
        XCTAssertEqual(urls[1].range, formatter.date(from: "02-04-2019 12:00")! ..< formatter.date(from: "02-04-2019 13:00")!)

        XCTAssertTrue(urls[2].url.absoluteString.hasSuffix("EURUSD/2019/03/02/13h_ticks.bi5"))
        XCTAssertEqual(urls[2].range, formatter.date(from: "02-04-2019 13:00")! ..< formatter.date(from: "02-04-2019 14:00")!)
    }

    func testURLFactoryCandles() {
        let factory = URLFactory()

        let date = formatter.date(from: "02-04-2019 11:00")!
        let url = try! factory.url(format: .candles(.bid), for: "EURUSD", date: date)

        XCTAssertTrue(url.absoluteString.hasSuffix("EURUSD/2019/03/02/BID_candles_min_1.bi5"))

        let end = formatter.date(from: "04-04-2019 19:00")!

        let urls = try! factory.url(format: .candles(.ask), for: "EURUSD", range: date ..< end)

        XCTAssertEqual(urls.count, 3)

        XCTAssertTrue(urls[0].url.absoluteString.hasSuffix("EURUSD/2019/03/02/ASK_candles_min_1.bi5"))

        XCTAssertTrue(urls[1].url.absoluteString.hasSuffix("EURUSD/2019/03/03/ASK_candles_min_1.bi5"))

        XCTAssertTrue(urls[2].url.absoluteString.hasSuffix("EURUSD/2019/03/04/ASK_candles_min_1.bi5"))
    }

    func testURLFactoryErrors() {
        let factory = URLFactory()
        typealias FactoryError = URLFactory.FactoryError

        XCTAssertThrowsError(try factory.url(format: .ticks, for: "EURUSD", year: 2000, month: 13, day: 1, hour: 1)) { error in
            XCTAssertEqual(error as! URLFactory.FactoryError, FactoryError.invalidMonth)
        }

        XCTAssertThrowsError(try factory.url(format: .ticks, for: "EURUSD", year: 2000, month: 0, day: 1, hour: 1)) { error in
            XCTAssertEqual(error as! URLFactory.FactoryError, FactoryError.invalidMonth)
        }

        XCTAssertThrowsError(try factory.url(format: .ticks, for: "EURUSD", year: 2000, month: 10, day: 0, hour: 1)) { error in
            XCTAssertEqual(error as! URLFactory.FactoryError, FactoryError.invalidDay)
        }

        XCTAssertThrowsError(try factory.url(format: .ticks, for: "EURUSD", year: 2000, month: 10, day: 32, hour: 1)) { error in
            XCTAssertEqual(error as! URLFactory.FactoryError, FactoryError.invalidDay)
        }

        XCTAssertThrowsError(try factory.url(format: .ticks, for: "EURUSD", year: 2000, month: 10, day: 5, hour: -1)) { error in
            XCTAssertEqual(error as! URLFactory.FactoryError, FactoryError.invalidHour)
        }

        XCTAssertThrowsError(try factory.url(format: .ticks, for: "EURUSD", year: 2000, month: 10, day: 5, hour: 24)) { error in
            XCTAssertEqual(error as! URLFactory.FactoryError, FactoryError.invalidHour)
        }

        XCTAssertThrowsError(try factory.url(format: .ticks, for: "", year: 2000, month: 10, day: 5, hour: 12)) { error in
            XCTAssertEqual(error as! URLFactory.FactoryError, FactoryError.invalidCurrency)
        }

        let begin = formatter.date(from: "02-04-2019 11:00")!
        let end = formatter.date(from: "02-04-2019 14:00")!

        let range = begin ..< end

        XCTAssertThrowsError(try factory.url(format: .ticks, for: "", range: range)) { error in
            XCTAssertEqual(error as! URLFactory.FactoryError, FactoryError.invalidCurrency)
        }
    }

    func testURLFactoryInfo() {
        let factory =  URLFactory()
        let headers = factory.instruments().headers

        XCTAssertNotNil( headers["Authority"] )
        XCTAssertNotNil( headers["Referer"] )
    }
}
