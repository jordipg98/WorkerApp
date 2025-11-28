//
//  ResidentCarWebSocketService.swift
//  ClientApp
//
//  Created by Jordi Pereira Gil on 28/11/25.
//

import Foundation
import Combine


final class ResidentCarWebSocketService: ObservableObject {
    var objectWillChange: ObservableObjectPublisher?


    private var socket: URLSessionWebSocketTask?
    @Published var lastUpdate: ResidentCarStatusUpdate?

    nonisolated struct ResidentCarStatusUpdate: Codable {
        let ownerId: Int64
        let carId: Int64
        let status: String
    }

    func connect() {
        guard let url = URL(string: "ws://192.168.1.141:8080/ws/car_status/worker") else { return }
        socket = URLSession.shared.webSocketTask(with: url)
        socket?.resume()

        listen()
    }

    func listen() {
        socket?.receive { result in
            switch result {
            case .success(.string(let text)):
                if let data = text.data(using: .utf8), let update = try? JSONDecoder().decode(ResidentCarStatusUpdate.self, from: data) {
                    DispatchQueue.main.async {
                        self.lastUpdate = update
                    }
                }
            case .success(.data(_)):
                break
            case .success(_):
                break
            case .failure(let error):
                print("WebSocketError: ", error)
            }

            self.listen()

        }
    }
}
