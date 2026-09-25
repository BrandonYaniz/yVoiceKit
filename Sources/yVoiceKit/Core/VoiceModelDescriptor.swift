public struct VoiceModelDescriptor: Codable, Hashable, Sendable, Identifiable {
    public var id: VoiceModelID
    public var displayName: String
    public var capabilities: Set<VoiceCapability>
    public var providerMetadata: [String: String]

    public init(
        id: VoiceModelID,
        displayName: String,
        capabilities: Set<VoiceCapability>,
        providerMetadata: [String: String] = [:]
    ) {
        self.id = id
        self.displayName = displayName
        self.capabilities = capabilities
        self.providerMetadata = providerMetadata
    }
}
