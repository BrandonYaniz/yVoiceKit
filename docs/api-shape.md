# API Shape

This document will be completed as the public API is implemented.

Initial public direction:

- `VoiceProviderID`
- `VoiceModelID`
- `VoiceCapability`
- `VoiceModelDescriptor`
- `VoiceProvider`
- `LocalVoiceProvider`
- `VoiceGenerationRequest`
- `VoiceConversionRequest`
- `VoiceReference`
- `VoiceGenerationEvent`
- `VoiceGenerationResult`
- `VoiceError`

The initial checked-in source intentionally contains only the smallest compileable identity/provider skeleton. Codex should implement the remainder in bounded stages defined under `.codex/BUILD_PLAN.md`.
