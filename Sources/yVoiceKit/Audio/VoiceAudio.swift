import AVFoundation
import Foundation

/// Interleaved, lossless Float32 PCM. Samples are frames × channels.
public struct VoicePCMBuffer: Codable, Hashable, Sendable {
    public let samples: [Float]
    public let sampleRate: Double
    public let channelCount: Int

    public init(samples: [Float], sampleRate: Double, channelCount: Int) throws {
        self.samples = samples
        self.sampleRate = sampleRate
        self.channelCount = channelCount
        try validate()
    }

    public var frameCount: Int { channelCount > 0 ? samples.count / channelCount : 0 }
    public var duration: TimeInterval { Double(frameCount) / sampleRate }

    public func validate() throws {
        guard sampleRate.isFinite, sampleRate > 0, channelCount > 0,
              !samples.isEmpty, samples.count.isMultiple(of: channelCount),
              samples.allSatisfy(\.isFinite) else {
            throw VoiceError.invalidReferenceAudio("PCM requires finite samples, a positive sample rate and complete, non-empty frames.")
        }
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(samples: values.decode([Float].self, forKey: .samples),
                      sampleRate: values.decode(Double.self, forKey: .sampleRate),
                      channelCount: values.decode(Int.self, forKey: .channelCount))
    }
}

public struct VoiceAudioMetadata: Codable, Hashable, Sendable {
    public let sampleRate: Double
    public let channelCount: Int
    public let frameCount: Int64
    public var duration: TimeInterval { Double(frameCount) / sampleRate }

    public init(sampleRate: Double, channelCount: Int, frameCount: Int64) throws {
        guard sampleRate.isFinite, sampleRate > 0, channelCount > 0, frameCount > 0 else {
            throw VoiceError.invalidReferenceAudio("Audio metadata must describe non-empty audio.")
        }
        self.sampleRate = sampleRate
        self.channelCount = channelCount
        self.frameCount = frameCount
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(sampleRate: values.decode(Double.self, forKey: .sampleRate),
                      channelCount: values.decode(Int.self, forKey: .channelCount),
                      frameCount: values.decode(Int64.self, forKey: .frameCount))
    }
}

/// File URLs are borrowed: the caller keeps them readable for the operation's lifetime.
/// Validation reads through AVFoundation; it never copies, rewrites or removes the input.
public enum VoiceAudioInput: Codable, Hashable, Sendable {
    case file(URL)
    case pcm(VoicePCMBuffer)

    public func validate() throws -> VoiceAudioMetadata {
        switch self {
        case .pcm(let pcm):
            try pcm.validate()
            return try VoiceAudioMetadata(sampleRate: pcm.sampleRate, channelCount: pcm.channelCount,
                                          frameCount: Int64(pcm.frameCount))
        case .file(let url):
            guard url.isFileURL, FileManager.default.isReadableFile(atPath: url.path) else {
                throw VoiceError.invalidReferenceAudio("Expected a readable local audio file.")
            }
            do {
                let file = try AVAudioFile(forReading: url)
                let metadata = try VoiceAudioMetadata(sampleRate: file.processingFormat.sampleRate,
                    channelCount: Int(file.processingFormat.channelCount), frameCount: file.length)
                guard let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: 1) else {
                    throw VoiceError.invalidReferenceAudio("Unable to allocate a PCM decoding buffer.")
                }
                try file.read(into: buffer, frameCount: 1)
                guard buffer.frameLength > 0 else {
                    throw VoiceError.invalidReferenceAudio("Audio file contains no decodable frames.")
                }
                return metadata
            } catch let error as VoiceError {
                throw error
            } catch {
                throw VoiceError.invalidReferenceAudio(String(describing: error))
            }
        }
    }
}
