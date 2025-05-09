//
//  PlayerActions.swift
//  Iris
//
//  Created by zepp on 5/9/25.
//

import Foundation
import AVFoundation
import AppKit

class PlayerActions: ObservableObject {
    @Published var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var currentTrack: String = "No Track Playing"
    @Published var currentArtwork: NSImage?

    @Published var musicFiles: [URL] = []

    func playTrack(url: URL) {
        audioPlayer?.stop()
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            currentTrack = url.deletingPathExtension().lastPathComponent
            isPlaying = true
            currentArtwork = MediaUtils.extractArtwork(from: url)
        } catch {
            print("Error playing track: \(error)")
        }
    }

    func togglePlayPause() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }

    func previousTrack() {
        guard let currentIndex = musicFiles.firstIndex(where: { $0.deletingPathExtension().lastPathComponent == currentTrack }) else { return }
        let previousIndex = (currentIndex - 1 + musicFiles.count) % musicFiles.count
        playTrack(url: musicFiles[previousIndex])
    }

    func nextTrack() {
        guard let currentIndex = musicFiles.firstIndex(where: { $0.deletingPathExtension().lastPathComponent == currentTrack }) else { return }
        let nextIndex = (currentIndex + 1) % musicFiles.count
        playTrack(url: musicFiles[nextIndex])
    }
}
