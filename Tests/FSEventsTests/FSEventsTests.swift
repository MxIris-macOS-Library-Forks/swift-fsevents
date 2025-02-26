import XCTest
@testable import FSEvents

@available(OSX 10.13, *)
final class FSEventsTests: XCTestCase {

    func testCreation() {

        let waitForEvents = expectation(description: "waitForEvents")
        let tmpURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)

        try! FileManager.default.createDirectory(at: tmpURL, withIntermediateDirectories: true, attributes: nil)

        var receivedEvents: [FSEvent] = []

        guard let eventStream = FSEventStream.forHost(
            pathsToWatch: [tmpURL.path],
            latency: 0.1,
            flags: [.fileEvents, .markSelf],
            callback: { (stream, events) in
                receivedEvents.append(contentsOf: events)
                waitForEvents.fulfill()
        })
        else {
            return XCTFail("eventStream nil")
        }

        eventStream.schedule(with: RunLoop.current, mode: .default)
        eventStream.set(dispatchQueue: .main)
        XCTAssertTrue(eventStream.start())

        let newURL = tmpURL.appendingPathComponent("test")
        try! Data().write(to: newURL, options: [])

        wait(for: [waitForEvents], timeout: 1.0)

        let expectedEvents: [FSEvent] = [
            .init(path: tmpURL.path, flags: [.itemCreated, .itemIsDir, .ownEvent], id: 0),
            .init(path: newURL.path, flags: [.itemCreated, .itemIsFile, .ownEvent], id: 0)
        ]

        XCTAssertTrue(receivedEvents.elementsEqual(expectedEvents, by: { (lhs, rhs) -> Bool in
            return URL(fileURLWithPath: lhs.path).resolvingSymlinksInPath()
                == URL(fileURLWithPath: rhs.path).resolvingSymlinksInPath()
                && lhs.flags == rhs.flags
        }))
    }

    static var allTests = [
        ("testCreation", testCreation),
    ]
}
