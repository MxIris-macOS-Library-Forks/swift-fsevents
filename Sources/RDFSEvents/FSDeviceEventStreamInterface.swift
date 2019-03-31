//
//  FSDeviceEventStreamInterface.swift
//  RDFSEvents
//
//  Created by Roman Dzieciol on 3/30/19.
//

import Foundation
import CoreFoundation
import CoreServices.FSEvents


@available(OSX 10.13, *)
public protocol FSDeviceEventStreamInterface: FSEventStreamInterface {

    var device: dev_t { get }

    /// Gets the UUID associated with a device, or NULL if not possible
    /// (for example, on read-only device).  A (non-NULL) UUID uniquely
    /// identifies a given stream of FSEvents.  If this (non-NULL) UUID
    /// is different than one that you stored from a previous run then
    /// the event stream is different (for example, because FSEvents were
    /// purged, because the disk was erased, or because the event ID
    /// counter wrapped around back to zero). A NULL return value
    /// indicates that "historical" events are not available, i.e., you
    /// should not supply a "sinceWhen" value to FSEventStreamCreate...()
    /// other than kFSEventStreamEventIdSinceNow.
    ///
    /// - Returns: The UUID associated with the stream of events on this device, or
    ///   NULL if no UUID is available (for example, on a read-only
    ///   device).  The UUID is stored on the device itself and travels
    ///   with it even when the device is attached to different computers.
    ///   Ownership follows the Copy Rule.
    func deviceUUID() -> UUID?

    /// Gets the last event ID for the given device that was returned
    /// before the given time.  This is conservative in the sense that if
    /// you then use the returned event ID as the sinceWhen parameter of
    /// FSEventStreamCreateRelativeToDevice() that you will not miss any
    /// events that happened since that time.  On the other hand, you
    /// might receive some (harmless) extra events. Beware: there are
    /// things that can cause this to fail to be accurate. For example,
    /// someone might change the system's clock (either backwards or
    /// forwards).  Or an external drive might be used on different
    /// systems without perfectly synchronized clocks.
    ///
    /// - Parameter beforeTime: The time as a CFAbsoluteTime whose value is the number of
    ///   seconds since Jan 1, 1970 (i.e. a posix style time_t).
    /// - Returns: The last event ID for the given device that was returned
    ///   before the given time.
    func lastEventId(beforeTime: CFAbsoluteTime) -> FSEventStream.EventId

    /// Purges old events from the persistent per-volume database
    /// maintained by the service. Can only be called by the root user.
    ///
    /// - Parameter eventId: The event ID.
    /// - Returns: True if it succeeds, otherwise False if it fails.
    func purgeEvents(upTo eventId: FSEventStream.EventId) -> Bool

}
