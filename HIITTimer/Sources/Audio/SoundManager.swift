import AVFoundation

/// Generates short synthesized tones at runtime so the app needs no bundled
/// sound assets, and plays them through a dedicated engine so cues are heard
/// even when the workout continues in the background.
final class SoundManager {
    static let shared = SoundManager()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44100
    private let format: AVAudioFormat

    private init() {
        format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        configureSession()
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        try? engine.start()
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers, .mixWithOthers])
        try? session.setActive(true)
    }

    private func tone(frequency: Double, duration: Double, volume: Float = 0.9) -> AVAudioPCMBuffer? {
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard frameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        let channel = buffer.floatChannelData![0]
        let fadeSamples = max(1, Int(sampleRate * 0.01))
        for i in 0..<Int(frameCount) {
            let t = Double(i) / sampleRate
            var sample = Float(sin(2.0 * .pi * frequency * t)) * volume
            if i < fadeSamples {
                sample *= Float(i) / Float(fadeSamples)
            } else if i > Int(frameCount) - fadeSamples {
                sample *= Float(Int(frameCount) - i) / Float(fadeSamples)
            }
            channel[i] = sample
        }
        return buffer
    }

    /// Schedules tones back-to-back on the player node so they play in order
    /// without racing dispatch timers.
    private func playSequence(_ tones: [(frequency: Double, duration: Double)], gap: Double = 0.05) {
        guard !tones.isEmpty else { return }
        if !engine.isRunning {
            try? engine.start()
        }
        for (index, entry) in tones.enumerated() {
            if let buffer = tone(frequency: entry.frequency, duration: entry.duration) {
                player.scheduleBuffer(buffer, at: nil)
            }
            if gap > 0, index < tones.count - 1, let silence = tone(frequency: 0, duration: gap, volume: 0) {
                player.scheduleBuffer(silence, at: nil)
            }
        }
        if !player.isPlaying {
            player.play()
        }
    }

    func playSessionStart() {
        playSequence([(880, 0.12), (1174.66, 0.2)])
    }

    func playSessionEnd() {
        playSequence([(659.25, 0.15), (783.99, 0.15), (1046.5, 0.3)])
    }

    func playWorkStart() {
        playSequence([(1046.5, 0.16)])
    }

    func playRestStart() {
        playSequence([(523.25, 0.16)])
    }

    func playCountdownTick() {
        playSequence([(440, 0.08)])
    }
}
