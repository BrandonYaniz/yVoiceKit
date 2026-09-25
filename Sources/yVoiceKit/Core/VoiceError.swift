public enum VoiceError: Error, Sendable, Equatable {
    case modelNotFound(VoiceModelID)
    case modelNotPrepared(VoiceModelID)
    case unsupportedCapability(VoiceCapability)
    case invalidRequest(String)
    case invalidReferenceAudio(String)
    case unsupportedLanguage(String)
    case generationFailed(String)
    case conversionFailed(String)
    case cancelled
    case providerFailed(String)
}
