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

extension VoiceError {
    /// Retains normalized errors and diagnostic text while avoiding runtime error types in app logic.
    public static func normalizing(_ error: any Error) -> VoiceError {
        if let error = error as? VoiceError { return error }
        if error is CancellationError { return .cancelled }
        return .providerFailed(String(describing: error))
    }
}
