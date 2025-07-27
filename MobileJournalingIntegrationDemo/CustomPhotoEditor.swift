import IMGLYEngine
import IMGLYPhotoEditor
import SwiftUI

/**
 CustomPhotoEditor.swift

 Editing screen for the photo scene demo. Lets users create a new scene with a picked image or edit an existing scene. Provides custom editing tools, allows saving changes, and generates a thumbnail for each project.
*/

struct CustomPhotoEditor: View {
  let settings = EngineSettings(
    license: "BZyb31yS-BJC4otHjtuVYnufYIHDV199U3DvmFdgCpsiAfkBT7HYHYzFaErCRRow",
    userID: UUID().uuidString,
  )

  @Environment(\.dismiss) private var dismiss
  @State private var pendingContext: NavigationBar.Context? = nil
  @State private var showExitAlert = false

  enum EditorMode {
    case create(image: URL)
    case edit(scene: URL)
  }

  let mode: EditorMode

  var body: some View {
    PhotoEditor(settings)
      .imgly.onCreate { engine in
        try await engine.addDefaultAssetSources(baseURL: Engine.assetBaseURL)

        switch mode {
        case .create(let image):
          try await engine.scene.create(fromImage: image)
          let pages = try engine.scene.getPages()
          guard let page = pages.first else {
            print("No pages were created in the scene after creating from image: \(image)")
            return
          }

          // Define custom page (photo) size if needed
          try engine.block.setWidth(page, value: 1080)
          try engine.block.setHeight(page, value: 1080)

          // Assign image fill to page
          let image = try engine.block.find(byType: .graphic).first!
          try engine.block.setFill(page, fill: engine.block.getFill(image))
          try engine.block.destroy(image)

        case .edit(let scene):
          do {
            try await engine.scene.loadArchive(from: scene)
            print("Scene loaded successfully from \(scene)")
          } catch {
            print("Failed to load scene from \(scene): \(error)")
          }
        }
      }
      .imgly.navigationBarItems { _ in
        NavigationBar.ItemGroup(placement: .topBarLeading) {
          NavigationBar.Buttons.closeEditor { context in
            DispatchQueue.main.async {
              showExitAlert = true
              pendingContext = context
            }
          }
        }
        NavigationBar.ItemGroup(placement: .topBarTrailing) {
          NavigationBar.Buttons.undo()
          NavigationBar.Buttons.redo()
          NavigationBar.Buttons.togglePreviewMode()
          NavigationBar.Buttons.export()
        }
      }
      .alert("Save changes before exiting?", isPresented: $showExitAlert) {
        Button("Save", role: .none) {
          Task {
            guard let editorEngine = pendingContext?.engine else {
              dismiss()
              return
            }

            let saveURL: URL

            switch mode {
            case .edit(let sceneURL):
              saveURL = sceneURL

            case .create(let imageURL):
              saveURL = sceneURL(from: imageURL)
            }

            do {
              let archive = try await editorEngine.scene.saveToArchive()
              try archive.write(to: saveURL)
              print("Scene saved at \(saveURL)")

              // Generate and save a thumbnail image alongside the scene archive
              // Uses engine's supported block.renderImage to generate the thumbnail
              let thumbURL = saveURL.deletingPathExtension().appendingPathExtension("jpg")

              if let currentPage = try editorEngine.scene.getCurrentPage() {
                let exportOptions = ExportOptions(
                  jpegQuality: 0.8,
                  targetWidth: 256,
                  targetHeight: 256
                )
                let imageData = try await editorEngine.block.export(
                  currentPage,
                  mimeType: .jpeg,
                  options: exportOptions
                )
                try imageData.write(to: thumbURL)
              }

              pendingContext?.eventHandler.send(.closeEditor)
              pendingContext = nil
            } catch {
              print("Saving failed: \(error)")
            }

            dismiss()
          }
        }
        Button("Dismiss", role: .destructive) { dismiss() }
        Button("Cancel", role: .cancel) {}
      }
  }

  private func sceneURL(from imageURL: URL) -> URL {
    imageURL.deletingPathExtension().appendingPathExtension("scene")
  }
}
