//
//  CarRequestDetails.swift
//  WorkerApp
//
//  Created by Jordi Pereira Gil on 26/11/25.
//

import SwiftUI
import OpenAPIURLSession

struct CarRequestDetails: View {
    @State private var userImage: UIImage = UIImage()
    @State private var requestDetails:
    Components.Schemas.ResidentCarDetailRequest = Components.Schemas.ResidentCarDetailRequest(status: "unavailable")
    @State private var status: CarStatus = .unavailable

    @Environment(\.dismiss) private var dismiss

    let ownerId: Int64
    let carId: Int64

    private let workerId: Int64 = 1
    var body: some View {
        List {
            Section("Car status") {
                Text(status.text)
                    .font(.title3)
            }

            Section("User data") {
                HStack{
                    Image(uiImage: requestDetails.owner?.profile_image?.toUIImage() ?? UIImage(systemName: "person.circle") ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())

                    Text(requestDetails.owner?.name ?? "")
                        .padding(.leading)
                }
            }

            Section("Car data") {
                Text("Make: \(requestDetails.car?.make ?? "")")
                    .font(.title3)

                Text("Model: \(requestDetails.car?.model ?? "") ")
                    .font(.title3)

                Text("License plate: \(requestDetails.car?.license_plate ?? "")")
                    .font(.title3)

                Text("Parking space: \(requestDetails.car?.parking_space ?? "")")
                    .font(.title3)
            }
        }
        .task {
            try? await getCarStatus()
        }
        if isNextStatusButtonNeeded(currentStatus: status) {
            Button(status.buttonText) {
                Task {
                    try? await changeCarStatus(status: status.nextStatus.value)
                    if status.statushaveToDismmiss() {
                        dismiss()
                    }
                }
            }
            .padding()
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
        }

    }

    let client: Client

    init(carId: Int64, ownerId: Int64) {
        self.client = Client(serverURL: try! Servers.Server1.url(), transport: URLSessionTransport())
        self.ownerId = ownerId
        self.carId = carId
    }

    private func getCarStatus() async throws{
        do {
            let response = try await client.getCarStatus(Operations.getCarStatus.Input(path: .init(ownerId: ownerId, carId: carId), query: .init(workerId: workerId)))
            switch response {
            case let .ok(okResponse):
                print("ok response")
                switch okResponse.body {
                case .json(let response):
                    self.requestDetails = response
                    self.status = CarStatus.getCarStatus(status: response.status)
                }

            case .undocumented(statusCode: let statusCode, _):
                print("Error: \(statusCode)")
            case .notFound(_):
                print("residentCar not found")
            }
        } catch {
            print("Error", error)
        }
    }

    private func changeCarStatus(status: String) async throws{
        do {
            guard let status = Components.Schemas.CarStatus(rawValue: status) else {
                print("Status inválido:", status)
                return
            }
            guard let ownerId = requestDetails.owner?.id else {return}
            guard let carId = requestDetails.car?.id else {return}

            let response = try await client.changeCarStatus(Operations.changeCarStatus.Input(
                path: .init(ownerId: ownerId, carId: carId), query: .init(workerId: workerId), body: .json(.init(status: Operations.changeCarStatus.Input.Body.jsonPayload.statusPayload(value1: status)))))
            switch response {
            case let .ok(okResponse):
                switch okResponse.body {
                case .json(let response):
                    self.status = CarStatus.getCarStatus(status: response.status)
                    self.requestDetails = response
                }

            case .undocumented(statusCode: let statusCode, _):
                print("Error: \(statusCode)")
            case .notFound(_):
                print("residentCar not found")
            case .badRequest(_):
                print("bad request")
            }
        } catch {
            print("Error ", error)
        }
    }


    private func isNextStatusButtonNeeded(currentStatus: CarStatus) -> Bool {
        ![.inGarage, .outside, .unavailable].contains(currentStatus)
    }
    
}

#Preview {
    CarRequestDetails(carId: 2, ownerId: 5)
}
