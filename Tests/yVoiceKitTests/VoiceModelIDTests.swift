import Testing
@testable import yVoiceKit

@Test
func voiceModelIDDescriptionIsProviderScoped() {
    let id = VoiceModelID(
        providerID: VoiceProviderID(rawValue: "qwen"),
        modelName: "example-model"
    )

    #expect(id.description == "qwen:example-model")
}
