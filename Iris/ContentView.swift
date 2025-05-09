import SwiftUI

struct ContentView: View {
    @StateObject private var player = PlayerActions()

    @State private var selectedTab: Tab = .home

    @State private var showNoMusicAlert = false
    @State private var alertMessage = ""

    @State private var artists: [String] = []
    @State private var albums: [String] = []

    @State private var selectedArtist: String?
    @State private var selectedAlbum: String?

    var body: some View {
        NavigationSplitView {
            sidebarView
        } detail: {
            detailView
        }
        .alert("No Music Found", isPresented: $showNoMusicAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(alertMessage)
        })
    }

    var sidebarView: some View {
        List(selection: $selectedTab) {
            Section("Browse") {
                Label("Home", systemImage: "house.fill")
                    .tag(Tab.home)
                Label("Albums", systemImage: "rectangle.stack.fill")
                    .tag(Tab.albums)
                Label("Artists", systemImage: "person.2.fill")
                    .tag(Tab.artists)
                Button(action: loadMusicDirectory) {
                    Label("Load Music Folder", systemImage: "folder")
                }
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .navigationTitle("Iris")
    }

    @ViewBuilder
    var detailView: some View {
        switch selectedTab {
        case .home:
            homeView
        case .albums:
            AlbumsView(albums: albums, selectedAlbum: $selectedAlbum, musicFiles: player.musicFiles, playTrack: player.playTrack)
        case .artists:
            ArtistsView(artists: artists, selectedArtist: $selectedArtist, musicFiles: player.musicFiles, playTrack: player.playTrack)
        }
    }

    var homeView: some View {
        VStack {
            if let artwork = player.currentArtwork {
                Image(nsImage: artwork)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(8)
                    .padding()
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.gray)
                    .padding()
            }

            Text(player.currentTrack)
                .font(.title)
                .padding()

            HStack(spacing: 40) {
                Button(action: player.previousTrack) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: player.togglePlayPause) {
                    Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .foregroundColor(player.isPlaying ? .white : .primary)
                        .padding(12)
                        .background(
                            player.isPlaying ? Color.accentColor.cornerRadius(8) : Color.clear.cornerRadius(8)
                        )
                }
                .buttonStyle(PlainButtonStyle())

                Button(action: player.nextTrack) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
        }
    }

    func loadMusicDirectory() {
        let dialog = NSOpenPanel()
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = false
        dialog.allowsMultipleSelection = false
        if dialog.runModal() == .OK, let directory = dialog.url {
            let files = MediaUtils.loadMusicFiles(from: directory)
            if files.isEmpty {
                alertMessage = "No music files were found in the selected folder."
                showNoMusicAlert = true
                artists = []
                albums = []
                selectedArtist = nil
                selectedAlbum = nil
                player.musicFiles = []
            } else {
                player.musicFiles = files
                let (newArtists, newAlbums) = MediaUtils.extractArtistsAndAlbums(from: files)
                artists = newArtists
                albums = newAlbums
                player.playTrack(url: files[0])
                selectedArtist = nil
                selectedAlbum = nil
                selectedTab = .home
            }
        }
    }
}
