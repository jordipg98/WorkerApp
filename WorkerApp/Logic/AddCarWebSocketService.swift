//
//  ResidentCarWebSocketService.swift
//  ClientApp
//
//  Created by Jordi Pereira Gil on 28/11/25.
//

import Foundation
import Combine
import OpenAPIRuntime

final class AddCarWebSocketService: ObservableObject {
    var objectWillChange: ObservableObjectPublisher?


    private var socket: URLSessionWebSocketTask?
    @Published var lastUpdate: Car?

    nonisolated struct Car: Codable {
        let owner_id: Int64
        let car_id: Int64
        let name: String
        let parking_space: String
        let status: String
        let user_image: OpenAPIRuntime.Base64EncodedData?

    }

    func connect() {
        guard let url = URL(string: "ws://192.168.1.141:8080/ws/car_status/new_request") else { return }
        socket = URLSession.shared.webSocketTask(with: url)
        socket?.resume()

        listen()
    }

    func listen() {
        socket?.receive { result in
            switch result {
            case .success(.string(let text)):
                if let data = text.data(using: .utf8) {
                    do {
                        try JSONDecoder().decode(Car.self, from: data)
                    }catch {
                        print(error)
                    }
                    if let update = try? JSONDecoder().decode(Car.self, from: data) {
                        DispatchQueue.main.async {
                            print("dentro del segundo")
                            self.lastUpdate = update
                            print(update)
                        }
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
