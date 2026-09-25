# Providers

## Qwen3-TTS

Qwen3-TTS is the first production provider target.

Preferred implementation path:
- native Swift,
- MLX on Apple Silicon,
- no Python runtime dependency.

Capabilities must be declared per actual model variant.

## Chatterbox

Chatterbox is the selected future voice-conversion / performance-preserving conversion target.

Do not add a production Chatterbox provider until a native, App-Store-compatible runtime path is selected and verified.

The core voice-conversion contract should be implemented and tested with mocks before the production provider exists.
