public struct VoiceModelDescriptor: Codable, Hashable, Sendable, Identifiable {
    public var id: VoiceModelID
    public var displayName: String
    public var capabilities: Set<VoiceCapability>
    /// Nil means language support has not been established.
    public var supportedLanguages: Set<String>?
    public var providerMetadata: [String: String]

    public init(
        id: VoiceModelID,
        displayName: String,
        capabilities: Set<VoiceCapability>,
        providerMetadata: [String: String] = [:],
        supportedLanguages: Set<String>? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.capabilities = capabilities
        self.providerMetadata = providerMetadata
        self.supportedLanguages = supportedLanguages
    }
}
