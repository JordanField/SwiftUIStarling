//
//  Extensions.swift
//  SwiftUIPulse
//
//  Created by Jordan Field on 14/07/2019.
//  Copyright © 2019 Jordan Field. All rights reserved.
//

import Foundation
import Combine

typealias ServerResponse = (data: Data, response: URLResponse)

extension Publisher where Output == ServerResponse {
  func validateHttpUrlResponse() -> Publishers.TryMap<Self, ServerResponse> {
    return self.tryMap { (data, response) in
      guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.responseNotHttp
      }
      guard (200...299).contains(httpResponse.statusCode) else {
        throw NetworkError.statusCode(httpResponse.statusCode)
      }
      return (data, response)
    }
  }
}
