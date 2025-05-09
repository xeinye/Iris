//
//  AlbumsView.swift
//  Iris
//
//  Created by zepp on 5/9/25.
//

import SwiftUI

struct AlbumsView: View {
    let albums: [String]
    @Binding var selectedAlbum: String?
    let musicFiles: [URL]
    let playTrack: (URL) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if albums.isEmpty {
                Text("No albums loaded").foregroundColor(.gray).padding()
            } else {
                List(selection: $selectedAlbum) {
                    ForEach(albums, id: \.self) { album in
                        Text(album)
                    }
                }
                .listStyle(.sidebar)
                .frame(minWidth: 200)

                if let selectedAlbum = selectedAlbum {
                    List(MediaUtils.songs(forAlbum: selectedAlbum, in: musicFiles), id: \.self) { url in
                        Text(url.deletingPathExtension().lastPathComponent)
                            .onTapGesture {
                                playTrack(url)
                            }
                    }
                    .frame(minWidth: 300)
                } else {
                    Text("Select an album to see songs")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
        }
        .padding()
    }
}
