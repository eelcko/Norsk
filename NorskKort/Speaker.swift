import AVFoundation

/// Озвучка норвежского текста системным голосом (nb-NO).
final class Speaker {
    static let shared = Speaker()

    private let synthesizer = AVSpeechSynthesizer()

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "nb-NO") ?? AVSpeechSynthesisVoice(language: "no-NO")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        synthesizer.speak(utterance)
    }
}
