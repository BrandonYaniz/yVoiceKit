public protocol LocalVoiceProvider: VoiceProvider {
    func isModelPrepared(_ modelID: VoiceModelID) async throws -> Bool
    func unloadModel(_ modelID: VoiceModelID) async throws
    func removeModel(_ modelID: VoiceModelID) async throws
}
