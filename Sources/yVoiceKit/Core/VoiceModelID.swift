public struct VoiceModelID: Codable, Hashable, Sendable, CustomStringConvertible {
    public var providerID: VoiceProviderID
    public var modelName: String

    public var revision: String?

    public var description: String {
        "\(providerID.rawValue):\(modelName)" + (revision.map { "@\($0)" } ?? "")
    }

    public init(providerID: VoiceProviderID, modelName: String, revision: String? = nil) {
        self.providerID = providerID
        self.modelName = modelName
        self.revision = revision
    }
}
