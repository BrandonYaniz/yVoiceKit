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
