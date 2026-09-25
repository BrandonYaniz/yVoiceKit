# API Shape

Stage 1 supplies provider-neutral value types. All new request, audio, result,
reference, settings and progress types are immutable, `Sendable`, `Codable` and
`Hashable`. Existing identity and descriptor setters remain source compatible.

- `VoiceProviderID` and `VoiceModelID`: provider-scoped identity, including an
  optional exact revision. Unversioned initializers and older encoded IDs remain valid.
- `VoiceCapability`, `VoiceModelDescriptor`: explicit capabilities and optional
  known language identifiers. Unknown languages are not universal support.
- `VoiceDescriptor`, `VoiceSelection`, `VoiceReference`: model-scoped preset
  descriptors, preset/reference/description selections, and borrowed audio with
  optional transcript, language and caller identifier.
- `VoicePCMBuffer`: finite, interleaved Float32 PCM with sample rate, channel count,
  computed frame count and duration. Construction and decoding validate its invariants.
- `VoiceAudioInput`: borrowed local file URL or in-memory PCM. `validate()` returns
  `VoiceAudioMetadata`; file validation opens an AVFoundation decoder and reads one
  frame, without copying or altering the source. This is a lightweight check, not
  a guarantee that every frame of a damaged recording is decodable.
- `VoiceGenerationRequest`: text, model, optional language/voice/instruction,
  settings and provider options. `validate(for:)` checks model identity, required
  capabilities, declared language support, text, settings and reference audio.
- `VoiceConversionRequest`: separate source performance and target voice with
  `VoiceConversionSettings`, including an explicit performance-preservation request.
- `VoiceGenerationSettings`: optional seed and maximum duration. A provider must
  reject unsupported settings rather than silently ignore them.
- `VoiceOptionValue` / `VoiceProviderOptions`: typed strings, integers, numbers,
  booleans, arrays, objects and null. Codable uses Swift's tagged enum representation;
  this is not an untagged arbitrary JSON interchange format.
- `VoiceGenerationResult`, `VoiceProvenance`, `VoiceSelectionProvenance`: caller-owned
  PCM, technical metadata, exact model identity, material request controls, reference
  identifier, optional runtime version and provider metadata. No reference recording
  or transcript is embedded in provenance. Providers must supply the resolved model
  revision in the request used to construct provenance when it becomes known.
- `VoiceGenerationEvent`: started, generation progress, genuine audio chunk, completed.
  Errors belong to a future execution stream's failure channel.
- `VoicePreparationProgress`, `VoiceGenerationProgress`: distinct progress domains;
  nil fraction is indeterminate, finite fractions must be in 0...1.
- `VoiceError.normalizing(_:)`: preserves existing voice errors, maps
  `CancellationError` to `.cancelled`, and retains other diagnostics as `.providerFailed`.

Request construction and decoding do not perform I/O. Providers must call request
validation before execution and additionally validate their runtime's specific
options, reference transcript requirements, presets and language conventions.

## Example: validate a reference request

```swift
import yVoiceKit

let id = VoiceModelID(providerID: .init(rawValue: "example"), modelName: "voice", revision: "v1")
let model = VoiceModelDescriptor(
    id: id, displayName: "Example",
    capabilities: [.textToSpeech, .referenceVoiceSynthesis],
    supportedLanguages: ["en"]
)
let reference = try VoicePCMBuffer(samples: [0, 0.1, -0.1, 0], sampleRate: 24_000, channelCount: 1)
let request = VoiceGenerationRequest(
    modelID: id, text: "The house was quiet.", language: "en",
    voice: .reference(VoiceReference(audio: .pcm(reference), identifier: "narrator")),
    settings: .init(seed: 42)
)
try request.validate(for: model)
```

This example validates the data contract; it does not generate speech.
`VoiceProvider` and `LocalVoiceProvider` retain their bootstrap discovery and lifecycle
methods. Generation/conversion execution, cancellation propagation, preparation
progress streams and the deterministic mock provider are Stage 2 work. Qwen remains
a placeholder. Defining an event type does not claim streaming runtime support.
