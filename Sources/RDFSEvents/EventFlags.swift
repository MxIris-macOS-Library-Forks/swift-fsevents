//
//  EventFlags.swift
//  RDFSEvents
//
//  Created by Roman Dzieciol on 3/30/19.
//

import Foundation
import CoreServices.FSEvents


@available(OSX 10.13, *)
extension FSEventStream {

    /// Flags that can be passed to your FSEventStreamCallback function.
    ///
    /// It is important to note that event flags are simply hints about the
    /// sort of operations that occurred at that path.
    ///
    /// Furthermore, the FSEvent stream should NOT be treated as a form of
    /// historical log that could somehow be replayed to arrive at the
    /// current state of the file system.
    ///
    /// The FSEvent stream simply indicates what paths changed; and clients
    /// need to reconcile what is really in the file system with their internal
    /// data model - and recognize that what is actually in the file system can
    /// change immediately after you check it.
    public struct EventFlags: FlagsSet {

        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        /**
         * There was some change in the directory at the specific path
         * supplied in this event.
         */
        public static let none = kFSEventStreamEventFlagNone.flag

        /**
         * Your application must rescan not just the directory given in the
         * event, but all its children, recursively. This can happen if there
         * was a problem whereby events were coalesced hierarchically. For
         * example, an event in /Users/jsmith/Music and an event in
         * /Users/jsmith/Pictures might be coalesced into an event with this
         * flag set and path=/Users/jsmith. If this flag is set you may be
         * able to get an idea of whether the bottleneck happened in the
         * kernel (less likely) or in your client (more likely) by checking
         * for the presence of the informational flags
         * kFSEventStreamEventFlagUserDropped or
         * kFSEventStreamEventFlagKernelDropped.
         */
        public static let mustScanSubDirs = kFSEventStreamEventFlagMustScanSubDirs.flag

        /**
         * The kFSEventStreamEventFlagUserDropped or
         * kFSEventStreamEventFlagKernelDropped flags may be set in addition
         * to the kFSEventStreamEventFlagMustScanSubDirs flag to indicate
         * that a problem occurred in buffering the events (the particular
         * flag set indicates where the problem occurred) and that the client
         * must do a full scan of any directories (and their subdirectories,
         * recursively) being monitored by this stream. If you asked to
         * monitor multiple paths with this stream then you will be notified
         * about all of them. Your code need only check for the
         * kFSEventStreamEventFlagMustScanSubDirs flag; these flags (if
         * present) only provide information to help you diagnose the problem.
         */
        public static let userDropped = kFSEventStreamEventFlagUserDropped.flag
        public static let kernelDropped = kFSEventStreamEventFlagKernelDropped.flag

        /**
         * If kFSEventStreamEventFlagEventIdsWrapped is set, it means the
         * 64-bit event ID counter wrapped around. As a result,
         * previously-issued event ID's are no longer valid arguments for the
         * sinceWhen parameter of the FSEventStreamCreate...() functions.
         */
        public static let eventIdsWrapped = kFSEventStreamEventFlagEventIdsWrapped.flag

        /**
         * Denotes a sentinel event sent to mark the end of the "historical"
         * events sent as a result of specifying a sinceWhen value in the
         * FSEventStreamCreate...() call that created this event stream. (It
         * will not be sent if kFSEventStreamEventIdSinceNow was passed for
         * sinceWhen.) After invoking the client's callback with all the
         * "historical" events that occurred before now, the client's
         * callback will be invoked with an event where the
         * kFSEventStreamEventFlagHistoryDone flag is set. The client should
         * ignore the path supplied in this callback.
         */
        public static let historyDone = kFSEventStreamEventFlagHistoryDone.flag

        /**
         * Denotes a special event sent when there is a change to one of the
         * directories along the path to one of the directories you asked to
         * watch. When this flag is set, the event ID is zero and the path
         * corresponds to one of the paths you asked to watch (specifically,
         * the one that changed). The path may no longer exist because it or
         * one of its parents was deleted or renamed. Events with this flag
         * set will only be sent if you passed the flag
         * kFSEventStreamCreateFlagWatchRoot to FSEventStreamCreate...() when
         * you created the stream.
         */
        public static let rootChanged = kFSEventStreamEventFlagRootChanged.flag

        /**
         * Denotes a special event sent when a volume is mounted underneath
         * one of the paths being monitored. The path in the event is the
         * path to the newly-mounted volume. You will receive one of these
         * notifications for every volume mount event inside the kernel
         * (independent of DiskArbitration). Beware that a newly-mounted
         * volume could contain an arbitrarily large directory hierarchy.
         * Avoid pitfalls like triggering a recursive scan of a non-local
         * filesystem, which you can detect by checking for the absence of
         * the MNT_LOCAL flag in the f_flags returned by statfs(). Also be
         * aware of the MNT_DONTBROWSE flag that is set for volumes which
         * should not be displayed by user interface elements.
         */
        public static let mount = kFSEventStreamEventFlagMount.flag

        /**
         * Denotes a special event sent when a volume is unmounted underneath
         * one of the paths being monitored. The path in the event is the
         * path to the directory from which the volume was unmounted. You
         * will receive one of these notifications for every volume unmount
         * event inside the kernel. This is not a substitute for the
         * notifications provided by the DiskArbitration framework; you only
         * get notified after the unmount has occurred. Beware that
         * unmounting a volume could uncover an arbitrarily large directory
         * hierarchy, although Mac OS X never does that.
         */
        public static let unmount = kFSEventStreamEventFlagUnmount.flag

        /**
         * A file system object was created at the specific path supplied in this event.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemCreated = kFSEventStreamEventFlagItemCreated.flag

        /**
         * A file system object was removed at the specific path supplied in this event.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemRemoved = kFSEventStreamEventFlagItemRemoved.flag

        /**
         * A file system object at the specific path supplied in this event had its metadata modified.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemInodeMetaMod = kFSEventStreamEventFlagItemInodeMetaMod.flag

        /**
         * A file system object was renamed at the specific path supplied in this event.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemRenamed = kFSEventStreamEventFlagItemRenamed.flag

        /**
         * A file system object at the specific path supplied in this event had its data modified.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemModified = kFSEventStreamEventFlagItemModified.flag

        /**
         * A file system object at the specific path supplied in this event had its FinderInfo data modified.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemFinderInfoMod = kFSEventStreamEventFlagItemFinderInfoMod.flag

        /**
         * A file system object at the specific path supplied in this event had its ownership changed.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let ItemChangeOwner = kFSEventStreamEventFlagItemChangeOwner.flag

        /**
         * A file system object at the specific path supplied in this event had its extended attributes modified.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemXattrMod = kFSEventStreamEventFlagItemXattrMod.flag

        /**
         * The file system object at the specific path supplied in this event is a regular file.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsFile = kFSEventStreamEventFlagItemIsFile.flag

        /**
         * The file system object at the specific path supplied in this event is a directory.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsDir = kFSEventStreamEventFlagItemIsDir.flag

        /**
         * The file system object at the specific path supplied in this event is a symbolic link.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsSymlink = kFSEventStreamEventFlagItemIsSymlink.flag

        /**
         * Indicates the event was triggered by the current process.
         * (This flag is only ever set if you specified the MarkSelf flag when creating the stream.)
         */
        public static let ownEvent = kFSEventStreamEventFlagOwnEvent.flag

        /**
         * Indicates the object at the specified path supplied in this event is a hard link.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsHardlink = kFSEventStreamEventFlagItemIsHardlink.flag

        /** Indicates the object at the specific path supplied in this event was the last hard link.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemIsLastHardlink = kFSEventStreamEventFlagItemIsLastHardlink.flag

        /**
         * The file system object at the specific path supplied in this event is a clone or was cloned.
         * (This flag is only ever set if you specified the FileEvents flag when creating the stream.)
         */
        public static let itemCloned = kFSEventStreamEventFlagItemCloned.flag

        public static var flagNames: [EventFlags: String] = [
            .mustScanSubDirs: "mustScanSubDirs",
            .userDropped: "userDropped",
            .kernelDropped: "kernelDropped",
            .eventIdsWrapped: "eventIdsWrapped",
            .historyDone: "historyDone",
            .rootChanged: "rootChanged",
            .mount: "mount",
            .unmount: "unmount",
            .itemCreated: "itemCreated",
            .itemRemoved: "itemRemoved",
            .itemInodeMetaMod: "itemInodeMetaMod",
            .itemRenamed: "itemRenamed",
            .itemModified: "itemModified",
            .itemFinderInfoMod: "itemFinderInfoMod",
            .ItemChangeOwner: "ItemChangeOwner",
            .itemXattrMod: "itemXattrMod",
            .itemIsFile: "itemIsFile",
            .itemIsDir: "itemIsDir",
            .itemIsSymlink: "itemIsSymlink",
            .ownEvent: "ownEvent",
            .itemIsHardlink: "itemIsHardlink",
            .itemIsLastHardlink: "itemIsLastHardlink",
            .itemCloned: "itemCloned"
        ]
    }
}

@available(OSX 10.13, *)
extension Int {

    fileprivate var flag: FSEventStream.EventFlags {
        return FSEventStream.EventFlags(rawValue: UInt32(self))
    }
}
