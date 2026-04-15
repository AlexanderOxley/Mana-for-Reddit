//
//  DetailPostLiveTextImageIOSViewModel.swift
//  Mana for Reddit
//
//  Created by GitHub Copilot on 15.04.2026.
//

#if os(iOS)
  import Combine
  import Foundation
  import UIKit

  @MainActor
  final class DetailPostLiveTextImageIOSViewModel: ObservableObject {
    @Published private(set) var image: UIImage?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private var loadTask: Task<Void, Never>?
    private var loadTaskID: UUID?

    private func debugLog(_ message: String) {
      print("[DetailPostLiveTextImageIOSViewModel] \(message)")
    }

    func loadImage(from url: URL) {
      debugLog("loadImage start url=\(url.absoluteString)")
      loadTask?.cancel()

      let taskID = UUID()
      loadTaskID = taskID
      image = nil
      errorMessage = nil
      isLoading = true

      loadTask = Task { [weak self] in
        guard let self else { return }

        do {
          var request = URLRequest(url: url)
          request.setValue("ManaForReddit/1.0", forHTTPHeaderField: "User-Agent")
          request.setValue("image/*,*/*;q=0.8", forHTTPHeaderField: "Accept")
          debugLog("request headers set ua=ManaForReddit/1.0 accept=image/*,*/*;q=0.8")

          let (data, response) = try await URLSession.shared.data(for: request)
          guard !Task.isCancelled else {
            debugLog("request cancelled url=\(url.absoluteString)")
            return
          }

          if let http = response as? HTTPURLResponse {
            debugLog(
              "response status=\(http.statusCode) mime=\(http.mimeType ?? "nil") bytes=\(data.count)"
            )
          } else {
            debugLog("response non-http bytes=\(data.count)")
          }

          if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            if self.loadTaskID == taskID {
              self.errorMessage = "The image request failed (\(http.statusCode))."
              self.isLoading = false
              self.debugLog("request failed status=\(http.statusCode) url=\(url.absoluteString)")
            }
            return
          }

          guard let loadedImage = UIImage(data: data) else {
            if self.loadTaskID == taskID {
              self.errorMessage = "The image could not be decoded."
              self.isLoading = false
              self.debugLog("decode failed bytes=\(data.count) url=\(url.absoluteString)")
            }
            return
          }

          if self.loadTaskID == taskID {
            self.image = loadedImage
            self.isLoading = false
            self.debugLog("decode success platform=iOS")
          }
        } catch {
          guard !Task.isCancelled else {
            debugLog("request cancelled in catch url=\(url.absoluteString)")
            return
          }
          if self.loadTaskID == taskID {
            self.errorMessage = "The image could not be loaded."
            self.isLoading = false
            self.debugLog(
              "request error url=\(url.absoluteString) error=\(error.localizedDescription)")
          }
        }
      }
    }

    deinit {
      loadTask?.cancel()
    }
  }
#endif
