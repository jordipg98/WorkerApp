//
//  CarRequestList.swift
//  WorkerApp
//
//  Created by Jordi Pereira Gil on 26/11/25.
//

import SwiftUI
import OpenAPIURLSession

struct CarRequestList: View {
    @StateObject private var ws: AddCarWebSocketService

    @State private var hasConnectedWS = false

    @State private var requests: [Components.Schemas.workerCarRequest] = []
    let requestType: String
    let workerId: Int64
    @State private var isDataLoaded = false
    var body: some View {
        NavigationView {
            VStack(){
                if !requests.isEmpty {
                    ScrollView {
                        VStack {
                            ForEach($requests, id: \.parking_space) { request in
                                CarRequestItem(workerId: workerId, request: request)

                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else if isDataLoaded {
                    VStack {
                        Label("No requests to show", systemImage: "info.circle")
                            .font(.largeTitle)
                            .padding([.horizontal, .top])
                        Text("Nothing to do here. Check back later.")
                            .padding(.bottom)
                    }
                    .frame(height: 150)

                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                }
            }
            .navigationTitle(workerId != -1 ? "Your requests" : "Pending Requests")
            .task {
                if requestType == "available" {
                    try? await getAvailableRequests()
                } else if workerId != -1 {
                    try? await getWorkerRequests()
                }
            }
            .onAppear() {
                if requestType == "available" && !hasConnectedWS {
                    hasConnectedWS = true
                    ws.connect()
                }
            }
            .onReceive(ws.$lastUpdate) { update in
                if requestType == "available" {
                    guard let update else { return }
                    let workerCar: Components.Schemas.workerCarRequest = Components.Schemas.workerCarRequest(name: update.name, parking_space: update.parking_space, status: update.status, user_image: update.user_image, owner_id: update.owner_id, car_id: update.car_id)

                    if (requests.first(where: { $0.parking_space == workerCar.parking_space}) != nil) {
                        requests.removeAll(where: { $0.parking_space == workerCar.parking_space})
                    } else  {
                        requests.append(workerCar)
                    }

                }
            }
        }
    }

    let client: Client

    init(requestType: String, workerId: Int64) {
        self.client = Client(serverURL: try! Servers.Server1.url(), transport: URLSessionTransport())
        self.requestType = requestType
        self.workerId = workerId

        _ws = StateObject(wrappedValue: AddCarWebSocketService())

    }

    private func getAvailableRequests() async throws {
        isDataLoaded = false
        let response = try await client.getAvailableRequests()
        switch response {
        case let .ok(okResponse):
            switch okResponse.body {
            case .json(let requests):
                self.requests = requests
            }
        case .undocumented(statusCode: let statusCode, _):
            print("Error \(statusCode)")
        }
        isDataLoaded = true
    }

    private func getWorkerRequests() async throws {
        isDataLoaded = false
        let response = try await client.getWorkerCarRequests( Operations.getWorkerCarRequests.Input(path: .init(workerId: workerId)) )

        switch response {
        case let .ok(okResponse):
            switch okResponse.body {
            case .json(let requests):
                self.requests = requests
            }
        case .undocumented(statusCode: let statusCode, _):
            print("Error \(statusCode)")
        case .notFound(_):
            print("Worker not found")
        }
        isDataLoaded = true
    }

}



#Preview {
    CarRequestList(requestType: "available", workerId: 1)
}
