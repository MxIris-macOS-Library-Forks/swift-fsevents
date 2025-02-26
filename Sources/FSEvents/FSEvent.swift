import Foundation

public struct FSEvent {
    public let path: String
    public let flags: FSEventStream.EventFlags
    public let id: FSEventStream.EventID

    init(
        path: String,
        flags: FSEventStream.EventFlags,
        id: FSEventStream.EventID
    ) {
        self.path = path
        self.flags = flags
        self.id = id
    }
}
