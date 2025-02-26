import Foundation
import CoreFoundation

@available(OSX 10.13, *)
extension FSEventStream {
    /// The callback used retain the info pointer.
    public static func retainCallback() -> CFAllocatorRetainCallBack {
        return { (pointer: UnsafeRawPointer?) -> UnsafeRawPointer? in
            guard let pointer = pointer else {
                return nil
            }
            let retained = Unmanaged<FSEventStream>.fromOpaque(pointer).retain()
            return UnsafeRawPointer(retained.toOpaque())
        }
    }

    /// The callback used release a retain on the info pointer.
    public static func releaseCallback() -> CFAllocatorReleaseCallBack {
        return { (pointer: UnsafeRawPointer?) in
            guard let pointer = pointer else {
                return
            }
            Unmanaged<FSEventStream>.fromOpaque(pointer).release()
        }
    }

    /// The callback used to create a descriptive string representation of
    /// the info pointer (or the data pointed to by the info pointer) for
    /// debugging purposes.
    public static func copyDescriptionCallback() -> CFAllocatorCopyDescriptionCallBack {
        return { (pointer: UnsafeRawPointer?) -> Unmanaged<CFString>? in
            guard let pointer = pointer else {
                return nil
            }
            let eventStream = pointer.load(as: FSEventStream.self)
            return Unmanaged.passRetained("\(eventStream)" as CFString)
        }
    }
}
