public struct VoiceProviderID: Codable, Hashable, Sendable, RawRepresentable, CustomStringConvertible {
    public var rawValue: String

    public var description: String {
        rawValue
    }

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
