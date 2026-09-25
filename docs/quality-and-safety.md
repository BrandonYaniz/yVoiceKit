# Quality and Safety Boundaries

yVoiceKit enforces technical correctness, not application policy.

## Technical invariants

- caller input audio is never modified,
- completed output is valid readable audio,
- unsupported capabilities fail explicitly,
- cancellation cannot report false success,
- provider/model identity is retained,
- material generation settings are retained in provenance,
- temporary files are not authoritative storage.

## Application-owned policy

Consuming applications own:
- voice consent and authorization,
- speaker verification policy,
- artistic acceptance,
- publication eligibility,
- manuscript accuracy validation,
- project history.

## Current implementation boundary

Stage 1 enforces value-level invariants and supplies explicit request validation.
PCM and progress invariants are also checked when decoding. Reference files remain
caller-owned and must stay readable through future execution. File validation is
read-only and accepts stereo audio when AVFoundation can decode it. It reads one
frame and does not scan an entire recording for corruption.

Results contain caller-owned interleaved Float32 PCM. Core does not create temporary
output files, resample inputs, or encode distribution formats. Provenance omits
reference audio and transcript; caller identifiers and provider metadata may still
be sensitive, so applications decide what to persist or share.

Cancellation normalization is implemented; execution cancellation, runtime output
validation and cleanup require the provider implementation in subsequent stages.
