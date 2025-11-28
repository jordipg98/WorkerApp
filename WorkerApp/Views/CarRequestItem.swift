//
//  CarRequestItem.swift
//  WorkerApp
//
//  Created by Jordi Pereira Gil on 26/11/25.
//

import SwiftUI
import OpenAPIURLSession

struct CarRequestItem: View {
    @Binding var request: Components.Schemas.workerCarRequest
    var body: some View {
        NavigationLink(destination: CarRequestDetails(carId: request.car_id, ownerId: request.owner_id)) {
            VStack {
                HStack {
                    Image(uiImage: ((request.user_image?.toUIImage() ?? UIImage(systemName: "person.circle")) ?? UIImage()))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .padding(.trailing)

                    VStack (alignment: .leading) {
                        Text(request.name)
                            .font(.headline)
                        Text("P. Space: \(request.parking_space)")
                    }
                    Spacer()
                    Text(CarStatus.getCarStatus(status: request.status).text)
                        .font(.headline)
                }
                .padding()
            }
            .background(Color(.secondarySystemBackground))
            .foregroundStyle(.foreground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
        }
    }
}

#Preview {
    /*@Previewable @State var request: Components.Schemas.workerAvailableCarRequest = nil
    CarRequestItem(request: $request)*/
}
