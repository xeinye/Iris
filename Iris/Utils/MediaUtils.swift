//
//  MediaUtils.swift
//  Iris
//
//  Created by zepp on 5/9/25.
//

import Foundation
import AVFoundation
import AppKit

struct MediaUtils {
    static func extractArtwork(from url: URL) -> NSImage? {
        let asset = AVAsset(url: url)
        for metadataItem in asset.commonMetadata {
            if metadataItem.commonKey == .commonKeyArtwork, let data = metadataItem.dataValue {
                return NSImage(data: data)
            }
        }
        for format in asset.availableMetadataFormats {
            for item in asset.metadata(forFormat: format) {
                if item.commonKey == .commonKeyArtwork, let data = item.dataValue {
                    return NSImage(data: data)
                }
            }
        }
        return nil
    }

    static func loadMusicFiles(from directory: URL) -> [URL] {
        var files: [URL] = []
        let fileManager = FileManager.default
        guard let enumerator = fileManager.enumerator(at: directory, includingPropertiesForKeys: nil) else {
            return files
        }

        for case let fileURL as URL in enumerator {
            if ["flac", "mp3", "m4a"].contains(fileURL.pathExtension.lowercased()) {
                files.append(fileURL)
            }
        }
        return files
    }

    static func extractArtistsAndAlbums(from musicFiles: [URL]) -> (artists: [String], albums: [String]) {
        var artistSet = Set<String>()
        var albumSet = Set<String>()

        for url in musicFiles {
            let asset = AVAsset(url: url)

            if let artistMetadata = asset.commonMetadata.first(where: { $0.commonKey == .commonKeyArtist }),
               let artist = artistMetadata.stringValue, !artist.isEmpty {
                artistSet.insert(artist)
            }

            if let albumMetadata = asset.commonMetadata.first(where: { $0.commonKey == .commonKeyAlbumName }),
               let album = albumMetadata.stringValue, !album.isEmpty {
                albumSet.insert(album)
            }
        }

        return (Array(artistSet).sorted(), Array(albumSet).sorted())
    }

    static func songs(forArtist artist: String, in musicFiles: [URL]) -> [URL] {
        musicFiles.filter { url in
            let asset = AVAsset(url: url)
            if let artistMetadata = asset.commonMetadata.first(where: { $0.commonKey == .commonKeyArtist }),
               let artistName = artistMetadata.stringValue {
                return artistName == artist
            }
            return false
        }
    }

    static func songs(forAlbum album: String, in musicFiles: [URL]) -> [URL] {
        musicFiles.filter { url in
            let asset = AVAsset(url: url)
            if let albumMetadata = asset.commonMetadata.first(where: { $0.commonKey == .commonKeyAlbumName }),
               let albumName = albumMetadata.stringValue {
                return albumName == album
            }
            return false
        }
    }
}
