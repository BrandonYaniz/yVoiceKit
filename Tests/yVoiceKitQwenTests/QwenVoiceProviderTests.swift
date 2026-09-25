import Testing
@testable import yVoiceKitQwen

@Test
func qwenProviderHasStableProviderID() {
    let provider = QwenVoiceProvider()
    #expect(provider.providerID.rawValue == "qwen")
}
