
import Foundation
import CoreFoundation
import CoreServices.FSEvents


@available(OSX 10.13, *)
extension FSEventStream {

    public static func forHost(pathsToWatch: [String],
                               sinceWhen: EventId = .now(),
                               latency: TimeInterval = 0.0,
                               flags: CreateFlags,
                               callback: @escaping CallbackBlock
        ) -> FSEventStream? {
        let stream = FSEventStream(
            pathsToWatch: pathsToWatch,
            sinceWhen: sinceWhen,
            latency: latency,
            flags: flags,
            callback: callback)

        var context = stream.eventStreamContext()
        let pathsToWatchCF = pathsToWatch as CFArray

        stream.streamRef = FSEventStreamCreate(
            nil,
            FSEventStream.streamCallback(),
            &context,
            pathsToWatchCF,
            sinceWhen.value,
            latency,
            flags.rawValue)

        guard stream.streamRef != nil else {
            return nil
        }
        return stream
    }
}

@available(OSX 10.13, *)
public class FSEventStream: FSEventStreamInterface {

    public let pathsToWatch: [String]
    public let sinceWhen: FSEventStream.EventId
    public let latency: TimeInterval
    public let flags: CreateFlags
    public let callback: CallbackBlock

    internal var streamRef: FSEventStreamRef! = nil

    public typealias CallbackBlock = (FSEventStream, [CallbackEvent]) -> Void

    public struct CallbackEvent {
        public let path: String
        public let flags: FSEventStream.EventFlags
        public let id: FSEventStream.EventId

        public init(
            path: String,
            flags: FSEventStream.EventFlags,
            id: FSEventStream.EventId)
        {
            self.path = path
            self.flags = flags
            self.id = id
        }
    }

    internal init(pathsToWatch: [String],
                  sinceWhen: EventId = .now(),
                  latency: TimeInterval = 0.0,
                  flags: CreateFlags,
                  callback: @escaping CallbackBlock
        ) {
        self.pathsToWatch = pathsToWatch
        self.sinceWhen = sinceWhen
        self.latency = latency
        self.flags = flags
        self.callback = callback
    }

    deinit {
        if streamRef != nil {
            stop()
            invalidate()
        }
    }

    public func start() -> Bool {
        return FSEventStreamStart(streamRef)
    }

    public func stop() {
        FSEventStreamStop(streamRef)
    }

    public func invalidate() {
        FSEventStreamInvalidate(streamRef)
    }

    public func set(dispatchQueue: DispatchQueue) {
        FSEventStreamSetDispatchQueue(streamRef, dispatchQueue)
    }

    public func schedule(with runLoop: RunLoop, mode: RunLoop.Mode) {
        FSEventStreamScheduleWithRunLoop(streamRef, runLoop.getCFRunLoop(), mode.rawValue as CFString)
    }

    public func unschedule(from runLoop: RunLoop, mode: RunLoop.Mode) {
        FSEventStreamUnscheduleFromRunLoop(streamRef, runLoop.getCFRunLoop(), mode.rawValue as CFString)
    }

    public func latestEventId() -> EventId {
        return EventId(integerLiteral: FSEventStreamGetLatestEventId(streamRef))
    }

    public static func currentEventId() -> EventId {
        return EventId(integerLiteral: FSEventsGetCurrentEventId())
    }

    public func flushSync() {
        FSEventStreamFlushSync(streamRef)
    }

    public func flushAsync() -> EventId {
        return EventId(integerLiteral: FSEventStreamFlushAsync(streamRef))
    }

    public func exclude(paths: [String]) -> Bool {
        return FSEventStreamSetExclusionPaths(streamRef, paths as CFArray)
    }
}

@available(OSX 10.13, *)
extension FSEventStream {

    internal func eventStreamContext() -> FSEventStreamContext {
        let contextInfoPointer = Unmanaged.passRetained(self).toOpaque()
        return FSEventStreamContext(
            version: 0,
            info: contextInfoPointer,
            retain: FSEventStream.retainCallback(),
            release: FSEventStream.releaseCallback(),
            copyDescription: FSEventStream.copyDescriptionCallback())
    }

    internal static func streamCallback() -> FSEventStreamCallback {
        return {
            ( streamRef: ConstFSEventStreamRef
            , clientCallBackInfo: UnsafeMutableRawPointer?
            , numEvents: Int
            , eventPaths: UnsafeMutableRawPointer
            , eventFlags: UnsafePointer<FSEventStreamEventFlags>
            , eventIds: UnsafePointer<FSEventStreamEventId>
            ) in

            guard let clientCallBackInfo = clientCallBackInfo else {
                return
            }

            let eventStream = Unmanaged<FSEventStream>.fromOpaque(clientCallBackInfo).takeUnretainedValue()
            eventStream.handle(streamRef: streamRef,
                               numEvents: numEvents,
                               eventPaths: eventPaths,
                               eventFlags: eventFlags,
                               eventIds: eventIds)
        }
    }

    internal func pathStrings(numEvents: Int, eventPaths: UnsafeMutableRawPointer) -> [String] {
        switch self.flags {
        case [.useCFTypes]:
            return eventPaths.load(as: CFArray.self) as! [String]
        default:
            let paths = eventPaths.bindMemory(to: UnsafeMutablePointer<CChar>.self, capacity: numEvents)
            return (0..<numEvents).map { String(cString: paths[$0]) }
        }
    }

    internal func handle
        ( streamRef: ConstFSEventStreamRef
        , numEvents: Int
        , eventPaths: UnsafeMutableRawPointer
        , eventFlags: UnsafePointer<FSEventStreamEventFlags>
        , eventIds: UnsafePointer<FSEventStreamEventId>
        ) {

        assert(streamRef == self.streamRef)

        let paths = pathStrings(numEvents: numEvents, eventPaths: eventPaths)
        var events: [CallbackEvent] = []

        for i in 0..<numEvents {
            let eventFlags = EventFlags(rawValue: eventFlags.advanced(by: i).pointee)
            let eventId = EventId(integerLiteral: eventIds.advanced(by: i).pointee)
            events.append(CallbackEvent(path: paths[i], flags: eventFlags, id: eventId))
        }

        self.callback(self, events)
    }
}

