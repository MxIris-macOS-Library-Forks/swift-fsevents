import Foundation
import CoreServices.FSEvents

@available(OSX 10.13, *)
extension FSEventStream {
    /// Event IDs that can be passed to the FSEventStreamCreate...()
    /// functions and FSEventStreamCallback(). They are monotonically
    /// increasing per system, even across reboots and drives coming and
    /// going. They bear no relation to any particular clock or timebase.
    public struct EventID: ExpressibleByIntegerLiteral {
        public typealias IntegerLiteralType = FSEventStreamEventId

        public var value: IntegerLiteralType

        public init(integerLiteral value: IntegerLiteralType) {
            self.value = value
        }

        public static func now() -> EventID {
            return EventID(integerLiteral: FSEventStreamEventId(kFSEventStreamEventIdSinceNow))
        }
    }
}
