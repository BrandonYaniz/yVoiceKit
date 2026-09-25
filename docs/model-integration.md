# Model Integration

Generic model identity, catalog, compatibility, selection, licensing metadata, and host-compatibility infrastructure belong in yLLMKit where practical.

yVoiceKit owns voice-model execution.

Do not build a second generic model manager inside yVoiceKit.

If yLLMKit's new model-selection API is not yet available during early yVoiceKit development, use a narrow temporary adapter and document the migration point.

## Stage 1 boundary

`VoiceModelID` currently carries only provider ID, model name and optional exact
revision. `VoiceModelDescriptor` adds voice capabilities, known language identifiers
and provider metadata. These are temporary execution-facing values, not a catalog,
selection engine or lifecycle policy. Stage 3 will map shared yLLMKit identities
into this boundary once its dependency API is verified; no yLLMKit dependency or
compatibility claim has been introduced yet.
