//
//  DetailPostLiveTextImageMacOSView.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 15.04.2026.
//

#if os(macOS)
  import AppKit
  import Foundation
  import SwiftUI
  import VisionKit

  struct DetailPostLiveTextImageMacOSView: View {
    let imageURL: URL

    @StateObject private var viewModel = DetailPostLiveTextImageMacOSViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
      AsyncImage(url: imageURL) { phase in
        switch phase {
        case .success(let image):
          ZStack(alignment: .topTrailing) {
            image
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(maxWidth: .infinity)
              .clipShape(RoundedRectangle(cornerRadius: 10))
              .overlay {
                if let nsImage = viewModel.image {
                  VisionKitOverlayRepresentable(image: nsImage, imageID: imageURL.absoluteString)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
              }

            imageActionsMenu
              .padding(10)
          }
        case .failure(let error):
          ContentUnavailableView(
            "Image unavailable",
            systemImage: "photo",
            description: Text(error.localizedDescription)
          )
          .frame(maxWidth: .infinity, minHeight: 220)
        default:
          ProgressView()
            .frame(maxWidth: .infinity, minHeight: 220)
        }
      }
      .task(id: imageURL) {
        viewModel.loadImage(from: imageURL)
      }
    }

    private var imageActionsMenu: some View {
      Menu {
        ShareLink(item: imageURL) {
          Label("Share image link", systemImage: "square.and.arrow.up")
        }

        if let nsImage = viewModel.image {
          Button {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([nsImage])
          } label: {
            Label("Copy image", systemImage: "doc.on.doc")
          }

          Button {
            downloadImageToDownloads(nsImage)
          } label: {
            Label("Download image", systemImage: "arrow.down.circle")
          }
        }

        Button {
          openURL(imageURL)
        } label: {
          Label("Open original", systemImage: "safari")
        }
      } label: {
        Label("Image actions", systemImage: "ellipsis.circle.fill")
          .labelStyle(.iconOnly)
          .font(.title3)
          .foregroundStyle(.primary)
          .padding(6)
          .background(.ultraThinMaterial, in: Circle())
      }
      .menuStyle(.borderlessButton)
      .help("Image actions")
    }

    private func downloadImageToDownloads(_ image: NSImage) {
      guard
        let downloadsDirectory = FileManager.default.urls(
          for: .downloadsDirectory, in: .userDomainMask
        ).first
      else {
        return
      }

      guard
        let tiffData = image.tiffRepresentation,
        let bitmap = NSBitmapImageRep(data: tiffData),
        let pngData = bitmap.representation(using: .png, properties: [:])
      else {
        return
      }

      var destination = downloadsDirectory.appendingPathComponent("reddit-image.png")
      var index = 2
      while FileManager.default.fileExists(atPath: destination.path) {
        destination = downloadsDirectory.appendingPathComponent("reddit-image-\(index).png")
        index += 1
      }

      do {
        try pngData.write(to: destination)
        print("[DetailPostLiveTextImageMacOSView] downloaded image path=\(destination.path)")
      } catch {
        print(
          "[DetailPostLiveTextImageMacOSView] download failed error=\(error.localizedDescription)")
      }
    }
  }

  // Transparent overlay representable — handles only VisionKit analysis, no image drawing.
  private struct VisionKitOverlayRepresentable: NSViewRepresentable {
    let image: NSImage
    let imageID: String

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeNSView(context: Context) -> NSView {
      print("[DetailPostLiveTextImageMacOSView] makeNSView")
      let v = NSView()
      v.wantsLayer = true
      v.layer?.backgroundColor = NSColor.clear.cgColor
      return v
    }

    func updateNSView(_ nsView: NSView, context: Context) {
      print("[DetailPostLiveTextImageMacOSView] updateNSView imageID=\(imageID)")
      context.coordinator.applyInteractionIfNeeded(on: nsView, image: image, imageID: imageID)
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
      coordinator.cancelPendingAnalysis()
    }

    final class Coordinator {
      private var analysisTask: Task<Void, Never>?
      private var lastAnalyzedID: String?
      @MainActor private weak var overlayView: ImageAnalysisOverlayView?

      func applyInteractionIfNeeded(on view: NSView, image: NSImage, imageID: String) {
        guard #available(macOS 13.0, *) else { return }
        guard lastAnalyzedID != imageID else { return }

        print("[DetailPostLiveTextImageMacOSView] applyInteraction imageID=\(imageID)")
        lastAnalyzedID = imageID
        analysisTask?.cancel()

        analysisTask = Task {
          let analyzer = ImageAnalyzer()
          let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
          print("[DetailPostLiveTextImageMacOSView] analyzer start imageID=\(imageID)")

          do {
            let analysis = try await analyzer.analyze(
              image, orientation: .up, configuration: configuration)
            guard !Task.isCancelled else {
              print("[DetailPostLiveTextImageMacOSView] analyzer cancelled imageID=\(imageID)")
              return
            }

            await MainActor.run {
              let overlay: ImageAnalysisOverlayView
              if let existing = self.overlayView {
                overlay = existing
              } else {
                let created = ImageAnalysisOverlayView()
                view.addSubview(created)
                created.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                  created.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                  created.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                  created.topAnchor.constraint(equalTo: view.topAnchor),
                  created.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                ])
                created.trackingImageView = nil
                created.preferredInteractionTypes = .automatic
                self.overlayView = created
                overlay = created
                print("[DetailPostLiveTextImageMacOSView] created overlay preferredTypes=automatic")
              }
              overlay.analysis = analysis
              print("[DetailPostLiveTextImageMacOSView] analyzer success imageID=\(imageID)")
            }
          } catch {
            print(
              "[DetailPostLiveTextImageMacOSView] analyzer error imageID=\(imageID) error=\(error.localizedDescription)"
            )
          }
        }
      }

      func cancelPendingAnalysis() { analysisTask?.cancel() }
      deinit { analysisTask?.cancel() }
    }
  }

  #Preview {
    DetailPostLiveTextImageMacOSView(
      imageURL: URL(
        string:
          "https://preview.redd.it/watching-the-boys-while-enjoying-a-cocktail-at-lost-v0-11yf8q6tjqtg1.jpeg?width=640&crop=smart&auto=webp&s=906d9f2f6435154fa99325501e0a1624672f00cd"
      )!
    )
    .frame(width: 500)
    .padding()
  }
#endif
