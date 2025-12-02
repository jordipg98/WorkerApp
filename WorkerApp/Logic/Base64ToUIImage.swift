//
//  StringToUIImage.swift
//  ClientApp
//
//  Created by Jordi Pereira Gil on 25/11/25.
//

import OpenAPIRuntime
import SwiftUI

extension Base64EncodedData {
    func toUIImage() -> UIImage {
        let fileData = Data(self.data)

        guard let base64String = String(data: fileData, encoding: .utf8),
              let imageData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters),
              let image = UIImage(data: imageData) else { return UIImage() }

        return image
    }
}
