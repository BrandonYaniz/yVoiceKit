# Model Integration

Generic model identity, catalog, compatibility, selection, licensing metadata, and host-compatibility infrastructure belong in yLLMKit where practical.

yVoiceKit owns voice-model execution.

Do not build a second generic model manager inside yVoiceKit.

If yLLMKit's new model-selection API is not yet available during early yVoiceKit development, use a narrow temporary adapter and document the migration point.
