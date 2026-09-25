# Architecture

## High-Level Pattern

```text
Consuming app/service
        ↓
    yVoiceKit
        ↓
   VoiceProvider
        ↓
Concrete provider product
        ↓
Local voice runtime/model
```

`yVoiceKit` owns voice execution abstractions.

Generic model identity/catalog/selection infrastructure belongs in `yLLMKit` where practical.

## Core Responsibilities

- provider-neutral voice identifiers,
- voice-model descriptors and capabilities,
- generation/conversion request types,
- generation events and results,
- normalized errors,
- audio/reference types,
- provider contracts,
- technical provenance.

## Provider Responsibilities

- model-specific request mapping,
- runtime preparation,
- generation,
- reference-voice handling,
- cancellation,
- provider-specific options,
- provider-specific errors,
- model/runtime dependencies.

## Core Must Not Own

- UI,
- application databases,
- manuscripts,
- Takes,
- publishing,
- legal consent workflows,
- translation,
- chat/LLM execution,
- DAW processing,
- generic project persistence.
