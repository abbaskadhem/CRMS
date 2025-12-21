//
//  NetworkChecker.swift
//  CRMS
//
//  Created by Abbas on 21/12/2025.
//

import Foundation
import Network

enum NetworkError: LocalizedError {
    case noInternet
    case serverUnavailable

    var errorDescription: String? {
          switch self {
          case .noInternet:
              return "No Internet Connection. Please check your internet connectivity and try again later."
          case .serverUnavailable:
              return "Server Unavailable. The server could not be reached. Please try again later."
          }
      }
    
}

func hasInternetConnection() async -> Bool {
    await withCheckedContinuation { continuation in
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetMonitor")

        var didResume = false

        monitor.pathUpdateHandler = { path in
            guard !didResume else { return }
            didResume = true

            continuation.resume(returning: path.status == .satisfied)
            monitor.cancel()
        }

        monitor.start(queue: queue)
    }
}
