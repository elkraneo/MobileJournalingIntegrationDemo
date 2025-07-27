# Photo Scene Demo

A simple SwiftUI demo showcasing how to build an image gallery and lightweight editor. Users can add photos, view them in a gallery with thumbnails, and open a basic editor to apply color overlays. All scenes and edits are saved temporarily for demonstration and learning purposes.

## Purpose
This project demonstrates core photo handling techniques in SwiftUI with IMG.LY CE.SDK:
- Picking images from the user's library
- Displaying a scrollable gallery of "scenes" (photos)
- Editing scenes with basic tools (add a color overlay)
- Saving and reloading images/thumbnails

It is intended for experimentation, prototyping, or as a reference for more advanced photo workflows.

## Features
- **Photo Gallery:** Add, view, and delete images with thumbnails
- **Scene Editor:** Edit an image by applying a color overlay and saving changes
- **Temporary Storage:** Scenes and thumbnails are saved in the device's temp folder

## Getting Started
1. Open the Xcode project (requires Xcode 15 or later)
2. Build and run on the iOS Simulator or a real device (iOS 17+ recommended)
3. Use "Add Photo" to import an image, tap "Edit" to modify it, and see changes reflected in the gallery

## Notes
- This code is for demonstration only. No data persists if the app is terminated or the OS clears the temp folder.
- No external dependencies required; all code is Swift and SwiftUI.
- For further extension or feedback, feel free to fork the repo or make a pull request.

---
