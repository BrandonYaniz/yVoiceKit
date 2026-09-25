public protocol VoiceProvider: Sendable {
    var providerID: VoiceProviderID { get }

    func availableModels() async throws -> [VoiceModelDescriptor]
    func prepareModel(_ modelID: VoiceModelID) async throws
}
