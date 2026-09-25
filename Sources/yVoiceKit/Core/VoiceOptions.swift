import Foundation

/// A typed, Codable escape hatch. Concrete providers own option names and validation.
public indirect enum VoiceOptionValue: Codable, Hashable, Sendable {
    case string(String)
    case integer(Int)
    case number(Double)
    case bool(Bool)
    case array([VoiceOptionValue])
    case object([String: VoiceOptionValue])
    case null
}

public typealias VoiceProviderOptions = [String: VoiceOptionValue]

public struct VoiceGenerationSettings: Codable, Hashable, Sendable {
    public let seed: UInt64?
    public let maximumDuration: TimeInterval?

    public init(seed: UInt64? = nil, maximumDuration: TimeInterval? = nil) {
        self.seed = seed
        self.maximumDuration = maximumDuration
    }

    public func validate() throws {
        if let maximumDuration, !maximumDuration.isFinite || maximumDuration <= 0 {
            throw VoiceError.invalidRequest("Maximum duration must be finite and positive.")
        }
    }
}

public struct VoiceConversionSettings: Codable, Hashable, Sendable {
    public let seed: UInt64?
    public let preservePerformance: Bool

    public init(seed: UInt64? = nil, preservePerformance: Bool = false) {
        self.seed = seed
        self.preservePerformance = preservePerformance
    }
}
