//
//  DetailPostLiveTextImageIOSView.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 15.04.2026.
//

#if os(iOS)
  import Photos
  import SwiftUI
  import UIKit
  import VisionKit

  struct DetailPostLiveTextImageIOSView: View {
    let imageURL: URL

    @StateObject private var viewModel = DetailPostLiveTextImageIOSViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
      AsyncImage(url: imageURL) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 220)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay {
              if let uiImage = viewModel.image {
                VisionKitOverlayRepresentable(image: uiImage, imageID: imageURL.absoluteString)
                  .clipShape(RoundedRectangle(cornerRadius: 10))
              }
            }
            .contextMenu {
              ShareLink(item: imageURL) {
                Label("Share image link", systemImage: "square.and.arrow.up")
              }
              if let uiImage = viewModel.image {
                Button {
                  UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
                } label: {
                  Label("Save image", systemImage: "square.and.arrow.down")
                }
              }
              Button {
                openURL(imageURL)
              } label: {
                Label("Open original", systemImage: "safari")
              }
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
        print("[DetailPostLiveTextImageIOSView] task triggered url=\(imageURL.absoluteString)")
        viewModel.loadImage(from: imageURL)
      }
    }
  }

  private struct VisionKitOverlayRepresentable: UIViewRepresentable {
    let image: UIImage
    let imageID: String

    func makeCoordinator() -> Coordinator {
      Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
      print("[DetailPostLiveTextImageIOSView] makeUIView")
      let view = UIView()
      view.backgroundColor = .clear
      view.isUserInteractionEnabled = true
      return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
      print("[DetailPostLiveTextImageIOSView] updateUIView imageID=\(imageID)")
      context.coordinator.applyInteractionIfNeeded(on: uiView, image: image, imageID: imageID)
    }

    static func dismantleUIView(_ uiView: UIView, coordinator: Coordinator) {
      coordinator.cancelPendingAnalysis()
    }

    final class Coordinator {
      private var analysisTask: Task<Void, Never>?
      private var lastAnalyzedID: String?
      private weak var interaction: ImageAnalysisInteraction?

      func applyInteractionIfNeeded(on view: UIView, image: UIImage, imageID: String) {
        guard #available(iOS 16.0, *) else {
          print("[DetailPostLiveTextImageIOSView] Vision interaction unavailable iOS<16")
          return
        }
        guard lastAnalyzedID != imageID else {
          print("[DetailPostLiveTextImageIOSView] skipping analysis unchanged imageID=\(imageID)")
          return
        }

        print("[DetailPostLiveTextImageIOSView] applyInteraction imageID=\(imageID)")

        lastAnalyzedID = imageID

        let interaction: ImageAnalysisInteraction
        if let existing = self.interaction {
          print("[DetailPostLiveTextImageIOSView] reusing existing interaction")
          interaction = existing
        } else {
          let created = ImageAnalysisInteraction()
          created.preferredInteractionTypes = [.textSelection, .dataDetectors]
          view.addInteraction(created)
          self.interaction = created
          interaction = created
          print(
            "[DetailPostLiveTextImageIOSView] created interaction preferredTypes=textSelection+dataDetectors"
          )
        }

        analysisTask?.cancel()
        analysisTask = Task {
          let analyzer = ImageAnalyzer()
          let configuration = ImageAnalyzer.Configuration([.text, .machineReadableCode])
          print("[DetailPostLiveTextImageIOSView] analyzer start imageID=\(imageID)")

          do {
            let analysis = try await analyzer.analyze(image, configuration: configuration)
            guard !Task.isCancelled else {
              print("[DetailPostLiveTextImageIOSView] analyzer cancelled imageID=\(imageID)")
              return
            }
            await MainActor.run {
              interaction.analysis = analysis
              print("[DetailPostLiveTextImageIOSView] analyzer success imageID=\(imageID)")
            }
          } catch {
            print(
              "[DetailPostLiveTextImageIOSView] analyzer error imageID=\(imageID) error=\(error.localizedDescription)"
            )
          }
        }
      }

      func cancelPendingAnalysis() {
        analysisTask?.cancel()
      }

      deinit {
        analysisTask?.cancel()
      }
    }
  }

  #Preview {
    DetailPostLiveTextImageIOSView(
      imageURL: URL(
        string:
          "https://preview.redd.it/watching-the-boys-while-enjoying-a-cocktail-at-lost-v0-11yf8q6tjqtg1.jpeg?width=640&crop=smart&auto=webp&s=906d9f2f6435154fa99325501e0a1624672f00cd"
      )!
    )
    .padding()
  }
#endif
