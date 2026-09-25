import AVFoundation
import Foundation
import Testing
@testable import yVoiceKit

private let modelID = VoiceModelID(providerID: .init(rawValue: "test"), modelName: "fixture", revision: "abc123")
private func pcm() throws -> VoicePCMBuffer {
    try .init(samples: [0, 0.25, -0.25, 0], sampleRate: 2, channelCount: 2)
}
private func roundTrip<T: Codable & Equatable>(_ value: T) throws {
    #expect(try JSONDecoder().decode(T.self, from: JSONEncoder().encode(value)) == value)
}
private func descriptor(_ capabilities: Set<VoiceCapability> = Set(VoiceCapability.allCases)) -> VoiceModelDescriptor {
    .init(id: modelID, displayName: "Fixture", capabilities: capabilities, supportedLanguages: ["en"])
}

@Test func identityAndDescriptorRoundTrips() throws {
    try roundTrip(modelID.providerID)
    try roundTrip(modelID)
    try roundTrip(descriptor())
    #expect(modelID.description == "test:fixture@abc123")
    #expect(modelID != VoiceModelID(providerID: modelID.providerID, modelName: modelID.modelName))
    let legacy = Data(#"{"providerID":"test","modelName":"fixture"}"#.utf8)
    #expect(try JSONDecoder().decode(VoiceModelID.self, from: legacy).revision == nil)
    for capability in VoiceCapability.allCases { try roundTrip(capability) }
}

@Test func audioAndReferenceRoundTrips() throws {
    let buffer = try pcm()
    #expect(buffer.frameCount == 2)
    #expect(buffer.duration == 1)
    try roundTrip(buffer)
    let input = VoiceAudioInput.pcm(buffer)
    try roundTrip(input)
    try roundTrip(input.validate())
    let reference = VoiceReference(audio: input, transcript: "Reference", language: "en", identifier: "ref-1")
    try roundTrip(reference)
    try roundTrip(VoiceReference(audioURL: URL(fileURLWithPath: "/tmp/reference.wav")))
    for selection in [VoiceSelection.reference(reference), .preset("speaker"), .description("Warm")] {
        try roundTrip(selection)
    }
    try roundTrip(VoiceDescriptor(id: "speaker", modelID: modelID, displayName: "Speaker", supportedLanguages: ["en"]))
}

@Test func invalidPCMIsRejectedIncludingOnDecode() throws {
    for (samples, rate, channels) in [([Float](), 2.0, 1), ([0], 0, 1), ([0], 2, 0),
                                     ([0, 1, 2], 2, 2), ([.nan], 2, 1), ([0], .infinity, 1)] {
        #expect(throws: VoiceError.self) { try VoicePCMBuffer(samples: samples, sampleRate: rate, channelCount: channels) }
    }
    #expect(throws: VoiceError.self) {
        try JSONDecoder().decode(VoicePCMBuffer.self, from: Data(#"{"samples":[],"sampleRate":2,"channelCount":1}"#.utf8))
    }
    #expect(throws: VoiceError.self) { try VoiceAudioMetadata(sampleRate: 2, channelCount: 1, frameCount: 0) }
}

@Test func optionsSettingsAndRequestsRoundTrip() throws {
    let options: VoiceProviderOptions = ["string": .string("value"), "int": .integer(42), "number": .number(0.7),
        "bool": .bool(true), "array": .array([.null]), "object": .object(["nested": .integer(1)])]
    try roundTrip(options)
    let settings = VoiceGenerationSettings(seed: 123, maximumDuration: 5)
    try roundTrip(settings)
    let request = VoiceGenerationRequest(modelID: modelID, text: "Hello", language: "en",
        voice: .reference(.init(audio: .pcm(try pcm()), identifier: "ref-1")), instruction: "Quietly",
        settings: settings, providerOptions: options)
    try request.validate(for: descriptor())
    try roundTrip(request)
    try request.validate(for: descriptor([.referenceVoiceSynthesis, .styleInstruction]))
    #expect(request.requiredCapabilities == [.referenceVoiceSynthesis, .styleInstruction])
    let conversion = VoiceConversionRequest(modelID: modelID, source: .pcm(try pcm()),
        targetVoice: .init(audio: .pcm(try pcm())), settings: .init(seed: 4, preservePerformance: true), providerOptions: options)
    try conversion.validate(for: descriptor())
    try roundTrip(conversion)
    try roundTrip(conversion.settings)
    #expect(conversion.requiredCapabilities == [.voiceConversion, .performancePreservingVoiceConversion])
    #expect(throws: VoiceError.unsupportedCapability(.performancePreservingVoiceConversion)) {
        try conversion.validate(for: descriptor([.voiceConversion]))
    }
}

@Test func requestValidationIsConservative() throws {
    #expect(throws: VoiceError.self) { try VoiceGenerationRequest(modelID: modelID, text: " \n").validate(for: descriptor()) }
    #expect(throws: VoiceError.unsupportedCapability(.presetVoices)) {
        try VoiceGenerationRequest(modelID: modelID, text: "Hello", voice: .preset("a")).validate(for: descriptor([.textToSpeech]))
    }
    #expect(throws: VoiceError.unsupportedLanguage("xx")) {
        try VoiceGenerationRequest(modelID: modelID, text: "Hello", language: "xx").validate(for: descriptor())
    }
    #expect(throws: VoiceError.unsupportedLanguage("en")) {
        try VoiceGenerationRequest(modelID: modelID, text: "Hello", language: "en").validate(for:
            .init(id: modelID, displayName: "Unknown languages", capabilities: [.textToSpeech]))
    }
    #expect(throws: VoiceError.modelNotFound(modelID)) {
        var wrong = descriptor()
        wrong.id.revision = "different"
        try VoiceGenerationRequest(modelID: modelID, text: "Hello").validate(for: wrong)
    }
    for limit in [0.0, -1, .infinity, .nan] {
        #expect(throws: VoiceError.self) { try VoiceGenerationSettings(maximumDuration: limit).validate() }
    }
}

@Test func resultsEventsAndProvenanceRoundTrip() throws {
    let request = VoiceGenerationRequest(modelID: modelID, text: "Hello", language: "en",
        voice: .reference(.init(audio: .pcm(try pcm()), transcript: "Private reference", identifier: "ref-1")),
        instruction: "Quietly", settings: .init(seed: 7), providerOptions: ["control": .integer(2)])
    let provenance = VoiceProvenance(request: request, runtimeVersion: "1.0", providerMetadata: ["device": "cpu"])
    try roundTrip(provenance)
    #expect(provenance.referenceIdentifier == "ref-1")
    #expect(provenance.modelID.revision == "abc123")
    #expect(provenance.settings == request.settings)
    #expect(provenance.providerOptions == request.providerOptions)
    let encoded = String(decoding: try JSONEncoder().encode(provenance), as: UTF8.self)
    #expect(!encoded.contains("Private reference"))
    #expect(!encoded.contains("samples"))
    let result = VoiceGenerationResult(audio: try pcm(), provenance: provenance)
    try roundTrip(result)
    #expect(result.duration == 1)
    #expect(result.sampleRate == 2)
    #expect(result.channelCount == 2)
    #expect(result.providerID == modelID.providerID)
    for event in [VoiceGenerationEvent.started(modelID), .progress(try .init(fractionCompleted: 0.5)),
                  .audioChunk(try pcm()), .completed(result)] { try roundTrip(event) }
    for voice in [VoiceSelection.preset("a"), .description("warm")] {
        let value = VoiceProvenance(request: .init(modelID: modelID, text: "Hello", voice: voice))
        try roundTrip(value)
        try roundTrip(value.voice)
    }
    let conversion = VoiceConversionRequest(modelID: modelID, source: .pcm(try pcm()),
        targetVoice: .init(audio: .pcm(try pcm()), language: "en", identifier: "target"))
    let converted = VoiceProvenance(request: conversion)
    try roundTrip(converted)
    #expect(converted.settings == nil)
    #expect(converted.conversionSettings == conversion.settings)
    #expect(converted.referenceIdentifier == "target")
}

@Test func progressAndNormalizedErrors() throws {
    try roundTrip(VoicePreparationProgress(message: "Loading"))
    try roundTrip(VoiceGenerationProgress(fractionCompleted: 1))
    for value in [-0.1, 1.1, .nan, .infinity] {
        #expect(throws: VoiceError.self) { try VoicePreparationProgress(fractionCompleted: value) }
        #expect(throws: VoiceError.self) { try VoiceGenerationProgress(fractionCompleted: value) }
    }
    #expect(VoiceError.normalizing(CancellationError()) == .cancelled)
    let errors: [VoiceError] = [.modelNotFound(modelID), .modelNotPrepared(modelID), .unsupportedCapability(.voiceCloning),
        .invalidRequest("x"), .invalidReferenceAudio("x"), .unsupportedLanguage("x"), .generationFailed("x"),
        .conversionFailed("x"), .cancelled, .providerFailed("x")]
    for error in errors { #expect(VoiceError.normalizing(error) == error) }
    struct RuntimeFailure: Error {}
    guard case .providerFailed(let message) = VoiceError.normalizing(RuntimeFailure()) else {
        Issue.record("Expected normalized runtime error"); return
    }
    #expect(message.contains("RuntimeFailure"))
}

@Test func fileValidationIsNonDestructive() throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? FileManager.default.removeItem(at: directory) }
    let url = directory.appendingPathComponent("stereo.wav")
    let format = try #require(AVAudioFormat(standardFormatWithSampleRate: 24_000, channels: 2))
    let buffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: 32))
    buffer.frameLength = 32
    let channels = try #require(buffer.floatChannelData)
    for channel in 0..<2 { for frame in 0..<32 { channels[channel][frame] = 0.25 } }
    do {
        var settings = format.settings
        settings[AVLinearPCMIsNonInterleaved] = false
        let file = try AVAudioFile(forWriting: url, settings: settings)
        try file.write(from: buffer)
    }
    let before = try Data(contentsOf: url)
    let metadata = try VoiceAudioInput.file(url).validate()
    #expect(metadata.channelCount == 2)
    #expect(metadata.sampleRate == 24_000)
    #expect(metadata.frameCount == 32)
    #expect(try Data(contentsOf: url) == before)
    let broken = directory.appendingPathComponent("broken.wav")
    try Data("not audio".utf8).write(to: broken)
    for invalid in [broken, directory.appendingPathComponent("missing.wav"), URL(string: "https://example.com/ref.wav")!] {
        #expect(throws: VoiceError.self) { try VoiceAudioInput.file(invalid).validate() }
    }
}
