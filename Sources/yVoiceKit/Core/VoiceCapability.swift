public enum VoiceCapability: String, Codable, Hashable, Sendable, CaseIterable {
    case textToSpeech
    case referenceVoiceSynthesis
    case voiceCloning
    case presetVoices
    case styleInstruction
    case multilingualSynthesis
    case streamingGeneration
    case voiceConversion
    case performancePreservingVoiceConversion
}
