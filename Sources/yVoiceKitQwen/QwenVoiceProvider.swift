import yVoiceKit

public struct QwenVoiceProvider: LocalVoiceProvider {
    public let providerID = VoiceProviderID(rawValue: "qwen")

    public init() {}

    public func availableModels() async throws -> [VoiceModelDescriptor] {
        []
    }

    public func prepareModel(_ modelID: VoiceModelID) async throws {
        throw VoiceError.providerFailed("Qwen provider implementation has not been added yet.")
    }

    public func isModelPrepared(_ modelID: VoiceModelID) async throws -> Bool {
        false
    }

    public func unloadModel(_ modelID: VoiceModelID) async throws {}

    public func removeModel(_ modelID: VoiceModelID) async throws {}
}
