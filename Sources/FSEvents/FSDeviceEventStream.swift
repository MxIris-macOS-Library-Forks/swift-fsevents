import Foundation
import CoreFoundation
import CoreServices.FSEvents

@available(OSX 10.13, *)
extension FSDeviceEventStream {
    public static func forDevice(
        _ device: dev_t,
        pathsToWatch: [String],
        sinceWhen: EventID = .now(),
        latency: TimeInterval = 0.0,
        flags: CreateFlags,
        callback: @escaping CallbackBlock
    ) -> FSDeviceEventStream? {
        let stream = FSDeviceEventStream(
            device: device,
            pathsToWatch: pathsToWatch,
            sinceWhen: sinceWhen,
            latency: latency,
            flags: flags,
            callback: callback
        )

        var context = stream.eventStreamContext()
        let pathsToWatchCF = pathsToWatch as CFArray

        stream.streamRef = FSEventStreamCreateRelativeToDevice(
            nil,
            FSEventStream.streamCallback(),
            &context,
            device,
            pathsToWatchCF,
            sinceWhen.value,
            latency,
            flags.rawValue
        )

        guard stream.streamRef != nil else {
            return nil
        }
        return stream
    }
}

@available(OSX 10.13, *)
public class FSDeviceEventStream: FSEventStream, FSDeviceEventStreamInterface {
    public let device: dev_t

    internal init(
        device: dev_t,
        pathsToWatch: [String],
        sinceWhen: EventID = .now(),
        latency: TimeInterval = 0.0,
        flags: CreateFlags,
        callback: @escaping CallbackBlock
    ) {
        self.device = device
        super.init(
            pathsToWatch: pathsToWatch,
            sinceWhen: sinceWhen,
            latency: latency,
            flags: flags,
            callback: callback
        )
    }

    public func deviceUUID() -> UUID? {
        guard let uuid = FSEventsCopyUUIDForDevice(device) else {
            return nil
        }
        return UUID(uuidString: CFUUIDCreateString(nil, uuid) as String)
    }

    public func lastEventId(beforeTime: CFAbsoluteTime) -> FSEventStream.EventID {
        return FSEventStream.EventID(integerLiteral: FSEventsGetLastEventIdForDeviceBeforeTime(device, beforeTime))
    }

    public func purgeEvents(upTo eventId: FSEventStream.EventID) -> Bool {
        return FSEventsPurgeEventsForDeviceUpToEventId(device, eventId.value)
    }
}
