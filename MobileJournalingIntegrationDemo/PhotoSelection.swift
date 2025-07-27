import Foundation
import PhotosUI
import SwiftUI

/**
 PhotoSelection.swift

 Entry screen for the photo scene demo. Shows a gallery of available scenes (images or projects) found in the temporary folder. Allows users to pick a new photo, view, or edit any scene. Each scene can be opened in the custom editor for further editing or creation.
*/

// Simplified demo for feature explanation, not production code.
struct PhotoSelection: View {
  @State private var selectedPickerItem: PhotosPickerItem?
  @State private var navigationPath = NavigationPath()
  @State private var savedScenes: [URL] = []

  private func reloadScenes() {
    let tempDir = FileManager.default.temporaryDirectory
    let sceneFiles = (try? FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil)) ?? []
    savedScenes = sceneFiles.filter { $0.pathExtension == "scene" }
  }

  private func thumbnailURL(for sceneURL: URL) -> URL {
    sceneURL.deletingPathExtension().appendingPathExtension("jpg")
  }

  var body: some View {
    NavigationStack(path: $navigationPath) {
      ScrollView {
        LazyVGrid(
          columns: [GridItem(.adaptive(minimum: 144, maximum: 144), spacing: 16)],
          spacing: 16
        ) {
          ForEach(savedScenes, id: \.self) { sceneURL in
            Button {
              navigationPath.append(sceneURL)
            } label: {
              Rectangle()
                .foregroundColor(.blue.opacity(0.2))
                .overlay(
                  VStack {
                    Spacer()
                    if let thumb = UIImage(contentsOfFile: thumbnailURL(for: sceneURL).path) {
                      Image(uiImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                        .cornerRadius(8)
                    } else {
                      VStack(spacing: 4) {
                        Image(systemName: "doc.richtext")
                          .imageScale(.large)
                        Text(sceneURL.lastPathComponent)
                          .font(.caption2)
                          .foregroundColor(.primary)
                          .lineLimit(1)
                      }
                      .padding(4)
                    }
                    Spacer()
                    Text(sceneURL.lastPathComponent)
                      .font(.caption2)
                      .foregroundColor(.primary)
                      .lineLimit(1)
                  }
                  .padding(4)
                )
                .aspectRatio(0.9, contentMode: .fit)
                .cornerRadius(16)
            }
          }
        }
        .padding()
      }
      .navigationTitle("Scenes")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          PhotosPicker(
            selection: $selectedPickerItem,
            matching: .images,
            photoLibrary: .shared()
          ) {
            Label("Pick Photo", systemImage: "photo.badge.plus")
          }
        }
      }
      .onAppear { reloadScenes() }
      .navigationDestination(for: URL.self) { url in
        if url.pathExtension == "scene" {
          CustomPhotoEditor(mode: .edit(scene: url))
        } else {
          CustomPhotoEditor(mode: .create(image: url))
        }
      }
    }
    .onChange(of: selectedPickerItem) { _, newItem in
      guard let newItem else { return }
      Task {
        if let url = try? await saveItemToTemporaryURL(item: newItem) {
          navigationPath.append(url)
          reloadScenes()
          selectedPickerItem = nil
        }
      }
    }
    .onChange(of: navigationPath) { _, newPath in
      if newPath.isEmpty {
        reloadScenes()
      }
    }
  }

  // Helper function to load and save the picked image
  private func saveItemToTemporaryURL(item: PhotosPickerItem) async throws -> URL? {
    guard let data = try? await item.loadTransferable(type: Data.self) else { return nil }
    let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
      UUID().uuidString + ".jpg"
    )
    try data.write(to: tempURL)
    return tempURL
  }
}

