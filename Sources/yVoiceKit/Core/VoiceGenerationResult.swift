import Foundation

/// Request inputs are deliberately omitted: provenance never embeds a reference recording.
public struct VoiceProvenance: Codable, Hashable, Sendable {
    public let modelID: VoiceModelID
    public var providerID: VoiceProviderID { modelID.providerID }
    public let settings: VoiceGenerationSettings?
    public let conversionSettings: VoiceConversionSettings?
    public let referenceIdentifier: String?
    public let language: String?
    public let voice: VoiceSelectionProvenance?
    public let instruction: String?
    public let providerOptions: VoiceProviderOptions
    public let runtimeVersion: String?
    public let providerMetadata: [String: String]

    public init(request: VoiceGenerationRequest, runtimeVersion: String? = nil,
                providerMetadata: [String: String] = [:]) {
        modelID = request.modelID
        settings = request.settings
        conversionSettings = nil
        language = request.language
        instruction = request.instruction
        providerOptions = request.providerOptions
        self.runtimeVersion = runtimeVersion
        self.providerMetadata = providerMetadata
        switch request.voice {
        case .reference(let reference):
            referenceIdentifier = reference.identifier
            voice = .reference
        case .preset(let id): referenceIdentifier = nil; voice = .preset(id)
        case .description(let text): referenceIdentifier = nil; voice = .description(text)
        case nil: referenceIdentifier = nil; voice = nil
        }
    }

    public init(request: VoiceConversionRequest, runtimeVersion: String? = nil,
                providerMetadata: [String: String] = [:]) {
        modelID = request.modelID
        settings = nil
        conversionSettings = request.settings
        referenceIdentifier = request.targetVoice.identifier
        language = request.targetVoice.language
        voice = .reference
        instruction = nil
        providerOptions = request.providerOptions
        self.runtimeVersion = runtimeVersion
        self.providerMetadata = providerMetadata
    }
}

public enum VoiceSelectionProvenance: Codable, Hashable, Sendable {
    case preset(String)
    case description(String)
    case reference
}

/// Caller-owned in-memory PCM; this value has no temporary-file lifecycle.
public struct VoiceGenerationResult: Codable, Hashable, Sendable {
    public let audio: VoicePCMBuffer
    public let provenance: VoiceProvenance
    public var modelID: VoiceModelID { provenance.modelID }
    public var providerID: VoiceProviderID { provenance.providerID }
    public var sampleRate: Double { audio.sampleRate }
    public var channelCount: Int { audio.channelCount }
    public var duration: TimeInterval { audio.duration }

    public init(audio: VoicePCMBuffer, provenance: VoiceProvenance) {
        self.audio = audio
        self.provenance = provenance
    }
}

/// Nil fraction means indeterminate progress. Preparation and generation use distinct types.
public struct VoicePreparationProgress: Codable, Hashable, Sendable {
    public let fractionCompleted: Double?
    public let message: String?

    public init(fractionCompleted: Double? = nil, message: String? = nil) throws {
        try validateFraction(fractionCompleted)
        self.fractionCompleted = fractionCompleted
        self.message = message
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(fractionCompleted: values.decodeIfPresent(Double.self, forKey: .fractionCompleted),
                      message: values.decodeIfPresent(String.self, forKey: .message))
    }
}

public struct VoiceGenerationProgress: Codable, Hashable, Sendable {
    public let fractionCompleted: Double?
    public let message: String?

    public init(fractionCompleted: Double? = nil, message: String? = nil) throws {
        try validateFraction(fractionCompleted)
        self.fractionCompleted = fractionCompleted
        self.message = message
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(fractionCompleted: values.decodeIfPresent(Double.self, forKey: .fractionCompleted),
                      message: values.decodeIfPresent(String.self, forKey: .message))
    }
}

private func validateFraction(_ fraction: Double?) throws {
    if let fraction, !fraction.isFinite || !(0...1).contains(fraction) {
        throw VoiceError.invalidRequest("Progress must be between zero and one, or nil when unknown.")
    }
}

public enum VoiceGenerationEvent: Codable, Hashable, Sendable {
    case started(VoiceModelID)
    case progress(VoiceGenerationProgress)
    /// Emitted only by providers with verified streaming support.
    case audioChunk(VoicePCMBuffer)
    case completed(VoiceGenerationResult)
}
