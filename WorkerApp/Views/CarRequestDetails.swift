//
//  CarRequestDetails.swift
//  WorkerApp
//
//  Created by Jordi Pereira Gil on 26/11/25.
//

import SwiftUI
import OpenAPIURLSession

struct CarRequestDetails: View {
    @StateObject private var ws: ResidentCarWebSocketService

    @State private var userImage: UIImage = UIImage()
    @State private var requestDetails:
    Components.Schemas.ResidentCarDetailRequest = Components.Schemas.ResidentCarDetailRequest(status: "unavailable")
    @State private var status: CarStatus = .unavailable
    @State var showingAlert: Bool = false
    @State var alertMessage = ""

    @Environment(\.dismiss) private var dismiss

    let ownerId: Int64
    let carId: Int64

    let workerId: Int64
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
        .alert(alertMessage, isPresented: $showingAlert) {
            Button("leave", role: .close) {
                dismiss()
            }
        }
        .onAppear() {
            ws.connect()
        }
        .onReceive(ws.$lastUpdate) { update in
            print("receive")
            guard let update,
                  let userId = requestDetails.owner?.id,
                  let carId = requestDetails.car?.id else { return }

            if update.car_id == carId && update.owner_id == userId {
                let newStatus = CarStatus.getCarStatus(status: update.status)
                if let janitorId = update.janitor?.id, janitorId != workerId {
                    alertMessage = "Request accepted by another worker"
                    showingAlert = true
                    return
                } else if update.janitor == nil && newStatus.statusHaveToDismmiss() &&
                            (self.status == .leavingRequested || self.status == .storingRequested){
                    print("dentro")
                    alertMessage = "The request was cancelled"
                    showingAlert = true
                    return
                }
                print("sigue")
                status = newStatus

                if newStatus.statusHaveToDismmiss() {
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }


            }
        }
        .task {
            try? await getCarStatus()
        }

        if isNextStatusButtonNeeded(currentStatus: status) && status != .outside && status != .inGarage {
            Button(status.buttonText) {
                Task {
                    try? await changeCarStatus(status: status.nextStatus.value)

                }
            }
            .padding()
            .buttonStyle(.glassProminent)
            .buttonSizing(.flexible)
        }

    }

    let client: Client

    init(carId: Int64, ownerId: Int64, workerId: Int64) {
        self.client = Client(serverURL: try! Servers.Server1.url(), transport: URLSessionTransport())
        self.ownerId = ownerId
        self.carId = carId
        self.workerId = workerId
        _ws = StateObject(wrappedValue: ResidentCarWebSocketService())
    }

    private func getCarStatus() async throws{
        do {
            let response = try await client.getCarStatus(Operations.getCarStatus.Input(path: .init(ownerId: ownerId, carId: carId), query: .init(workerId: workerId)))
            switch response {
            case let .ok(okResponse):
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
            guard let ownerId = requestDetails.owner?.id, let carId = requestDetails.car?.id else {return}

            try await client.changeCarStatus(Operations.changeCarStatus.Input(
                path: .init(ownerId: ownerId, carId: carId), query: .init(workerId: workerId), body: .json(.init(status: Operations.changeCarStatus.Input.Body.jsonPayload.statusPayload(value1: status)))))
        } catch {
            print("Error ", error)
        }
    }


    private func isNextStatusButtonNeeded(currentStatus: CarStatus) -> Bool {
        ![.inGarage, .outside, .unavailable].contains(currentStatus)
    }

}

#Preview {
    CarRequestDetails(carId: 2, ownerId: 5, workerId: 2)
}
