import Foundation

public struct VoiceReference: Codable, Hashable, Sendable {
    public let audio: VoiceAudioInput
    public let transcript: String?
    public let language: String?
    public let identifier: String?

    public init(audio: VoiceAudioInput, transcript: String? = nil, language: String? = nil,
                identifier: String? = nil) {
        self.audio = audio
        self.transcript = transcript
        self.language = language
        self.identifier = identifier
    }

    public init(audioURL: URL, transcript: String? = nil, language: String? = nil,
                identifier: String? = nil) {
        self.init(audio: .file(audioURL), transcript: transcript, language: language, identifier: identifier)
    }
}

public enum VoiceSelection: Codable, Hashable, Sendable {
    case preset(String)
    case reference(VoiceReference)
    case description(String)
}

public struct VoiceDescriptor: Codable, Hashable, Sendable, Identifiable {
    public let id: String
    public let modelID: VoiceModelID
    public let displayName: String
    /// Nil means unknown, never universal support.
    public let supportedLanguages: Set<String>?
    public let providerMetadata: [String: String]

    public init(id: String, modelID: VoiceModelID, displayName: String,
                supportedLanguages: Set<String>? = nil, providerMetadata: [String: String] = [:]) {
        self.id = id
        self.modelID = modelID
        self.displayName = displayName
        self.supportedLanguages = supportedLanguages
        self.providerMetadata = providerMetadata
    }
}
