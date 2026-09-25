# yVoiceKit

`yVoiceKit` is a local-first Swift package for voice generation and voice transformation on Apple platforms.

The package provides a small provider-neutral core for text-to-speech, reference-voice synthesis, and future voice-conversion workflows, with concrete provider products added separately.

The initial production provider target is Qwen3-TTS through a native Swift/MLX implementation. A future Chatterbox provider is planned for voice conversion / performance-preserving transformation once a native, App-Store-compatible integration path is available.

## Status

Pre-alpha.

The public API is not stable yet.

## Developer

Brandon Yaniz

## License

BSD 3-Clause. See `LICENSE`.

## Goals

- Local-first voice generation on Apple Silicon.
- Provider-neutral Swift APIs.
- Explicit model and provider identity.
- Reference-voice synthesis.
- Future speech-to-speech / voice-conversion support.
- Cancellable model preparation and generation.
- Typed capabilities and normalized errors.
- Lossless generated audio plus technical metadata and provenance.
- No dependency on application-specific document or project models.

## Non-Goals

`yVoiceKit` does not own:

- manuscript management,
- Takes or performance revisions,
- publishing workflows,
- voice-consent policy,
- translation,
- LLM/chat execution,
- transcription or forced alignment,
- mastering or DAW-style editing,
- project persistence.

Those responsibilities belong to consuming applications or separate libraries.

## Package Products

```text
yVoiceKit
    Provider-neutral voice APIs and shared types.

yVoiceKitQwen
    Qwen3-TTS provider implementation.
```

Future provider products may be added only when a concrete, maintainable implementation exists.

## Relationship to yLLMKit

`yLLMKit` and `yVoiceKit` are sibling libraries.

`yLLMKit` owns reusable model identity, catalog, compatibility, selection, and model-metadata infrastructure.

`yVoiceKit` owns voice execution.

The libraries should share model identity/catalog infrastructure where practical without coupling voice generation to chat request/response types.

## Repository Layout

```text
yVoiceKit/
├── .codex/                 # Private Codex planning/build instructions
├── Sources/
│   ├── yVoiceKit/
│   │   ├── Core/
│   │   ├── Audio/
│   │   └── Providers/
│   └── yVoiceKitQwen/
├── Tests/
│   ├── yVoiceKitTests/
│   └── yVoiceKitQwenTests/
├── docs/
├── Package.swift
├── README.md
└── LICENSE
```

## Build

```sh
swift build
swift test
```

Full Xcode is required for live MLX work that depends on Metal tooling.

## Xcode

Because this is a Swift package, no `.xcodeproj` is required. Open the package directory or `Package.swift` directly in Xcode and Xcode will create the workspace view automatically.

## Development Principles

- Keep the core UI-neutral.
- Prefer typed APIs over provider metadata dictionaries.
- Keep provider-specific dependencies in provider products.
- Never mutate caller-owned input audio.
- Make model capabilities explicit and conservative.
- Preserve exact model/runtime provenance when material.
- Keep default CI independent of multi-gigabyte model downloads.
- Do not add generic abstractions until there is a concrete second use.
