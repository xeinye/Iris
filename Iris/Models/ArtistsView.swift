//
//  ArtistsView.swift
//  Iris
//
//  Created by zepp on 5/9/25.
//

import SwiftUI

struct ArtistsView: View {
    let artists: [String]
    @Binding var selectedArtist: String?
    let musicFiles: [URL]
    let playTrack: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if artists.isEmpty {
                Text("No artists loaded").foregroundColor(.gray).padding()
            } else {
                List(selection: $selectedArtist) {
                    ForEach(artists, id: \.self) { artist in
                        Text(artist)
                    }
                }
                .listStyle(.sidebar)
                .frame(minWidth: 200)

                if let selectedArtist = selectedArtist {
                    List(MediaUtils.songs(forArtist: selectedArtist, in: musicFiles), id: \.self) { url in
                        Text(url.deletingPathExtension().lastPathComponent)
                            .onTapGesture {
                                playTrack(url)
                            }
                    }
                    .frame(minWidth: 300)
                } else {
                    Text("Select an artist to see songs")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .padding()
    }
}
