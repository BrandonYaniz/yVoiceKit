public struct VoiceModelID: Codable, Hashable, Sendable, CustomStringConvertible {
    public var providerID: VoiceProviderID
    public var modelName: String

    public var description: String {
        "\(providerID.rawValue):\(modelName)"
    }

    public init(providerID: VoiceProviderID, modelName: String) {
        self.providerID = providerID
        self.modelName = modelName
    }
}
