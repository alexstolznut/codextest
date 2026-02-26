import AVFoundation
import Foundation
import UIKit

final class AudioManager {
    static let shared = AudioManager()

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let sampleRate: Double = 44_100
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let notifier = UINotificationFeedbackGenerator()

    private init() {
        setupEngine()
        impactSoft.prepare()
        impactRigid.prepare()
        notifier.prepare()
    }

    func playPaddleHit() {
        impactSoft.impactOccurred(intensity: 0.7)
        scheduleTone(frequency: 740, duration: 0.05, gain: 0.18)
    }

    func playWallHit() {
        impactRigid.impactOccurred(intensity: 0.45)
        scheduleTone(frequency: 460, duration: 0.04, gain: 0.14)
    }

    func playScore() {
        notifier.notificationOccurred(.success)
        scheduleTone(frequency: 560, duration: 0.05, gain: 0.19)
        scheduleTone(frequency: 880, duration: 0.08, gain: 0.18, delay: 0.03)
    }

    func playSpeedUpAccent() {
        scheduleTone(frequency: 980, duration: 0.04, gain: 0.16)
    }

    private func setupEngine() {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
            try engine.start()
            player.play()
        } catch {
            // Silent fail to avoid interrupting gameplay if audio session is unavailable.
        }
    }

    private func scheduleTone(frequency: Double, duration: Double, gain: Double, delay: Double = 0) {
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1),
              let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(sampleRate * duration)) else {
            return
        }

        let frames = Int(sampleRate * duration)
        buffer.frameLength = AVAudioFrameCount(frames)
        let twoPi = 2.0 * Double.pi

        if let channel = buffer.floatChannelData?.pointee {
            for frame in 0..<frames {
                let t = Double(frame) / sampleRate
                let env = exp(-t * 18)
                channel[frame] = Float(sin(twoPi * frequency * t) * env * gain)
            }
        }

        if delay <= 0 {
            player.scheduleBuffer(buffer, at: nil, options: [])
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                self?.player.scheduleBuffer(buffer, at: nil, options: [])
            }
        }
    }
}
