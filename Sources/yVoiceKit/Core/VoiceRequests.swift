import Foundation

public struct VoiceGenerationRequest: Codable, Hashable, Sendable {
    public let modelID: VoiceModelID
    public let text: String
    /// Provider-documented language identifier. No implicit locale fallback.
    public let language: String?
    public let voice: VoiceSelection?
    public let instruction: String?
    public let settings: VoiceGenerationSettings
    public let providerOptions: VoiceProviderOptions

    public init(modelID: VoiceModelID, text: String, language: String? = nil,
                voice: VoiceSelection? = nil, instruction: String? = nil,
                settings: VoiceGenerationSettings = .init(), providerOptions: VoiceProviderOptions = [:]) {
        self.modelID = modelID
        self.text = text
        self.language = language
        self.voice = voice
        self.instruction = instruction
        self.settings = settings
        self.providerOptions = providerOptions
    }

    public var requiredCapabilities: Set<VoiceCapability> {
        var result: Set<VoiceCapability> = [.textToSpeech]
        switch voice {
        case .reference: result = [.referenceVoiceSynthesis]
        case .preset: result.insert(.presetVoices)
        case .description: result.insert(.styleInstruction)
        case nil: break
        }
        if instruction != nil { result.insert(.styleInstruction) }
        return result
    }

    /// Providers call this before execution, then validate their own options and variant constraints.
    public func validate(for model: VoiceModelDescriptor) throws {
        try validateModel(modelID, model: model, capabilities: requiredCapabilities, language: language)
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw VoiceError.invalidRequest("Target text must not be empty.")
        }
        try settings.validate()
        switch voice {
        case .reference(let reference): _ = try reference.audio.validate()
        case .preset(let value), .description(let value):
            guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw VoiceError.invalidRequest("Voice selection must not be empty.")
            }
        case nil: break
        }
    }
}

/// Speech-to-speech has its own contract; it is never TTS with empty text.
public struct VoiceConversionRequest: Codable, Hashable, Sendable {
    public let modelID: VoiceModelID
    public let source: VoiceAudioInput
    public let targetVoice: VoiceReference
    public let settings: VoiceConversionSettings
    public let providerOptions: VoiceProviderOptions

    public init(modelID: VoiceModelID, source: VoiceAudioInput, targetVoice: VoiceReference,
                settings: VoiceConversionSettings = .init(), providerOptions: VoiceProviderOptions = [:]) {
        self.modelID = modelID
        self.source = source
        self.targetVoice = targetVoice
        self.settings = settings
        self.providerOptions = providerOptions
    }

    public var requiredCapabilities: Set<VoiceCapability> {
        settings.preservePerformance ? [.voiceConversion, .performancePreservingVoiceConversion] : [.voiceConversion]
    }

    public func validate(for model: VoiceModelDescriptor) throws {
        try validateModel(modelID, model: model, capabilities: requiredCapabilities, language: nil)
        _ = try source.validate()
        _ = try targetVoice.audio.validate()
    }
}

private func validateModel(_ id: VoiceModelID, model: VoiceModelDescriptor,
                           capabilities: Set<VoiceCapability>, language: String?) throws {
    guard id == model.id else { throw VoiceError.modelNotFound(id) }
    for capability in capabilities.sorted(by: { $0.rawValue < $1.rawValue }) {
        guard model.capabilities.contains(capability) else { throw VoiceError.unsupportedCapability(capability) }
    }
    if let language {
        guard let supported = model.supportedLanguages, supported.contains(language) else {
            throw VoiceError.unsupportedLanguage(language)
        }
    }
}
