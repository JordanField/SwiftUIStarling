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

extension DateFormatter {
  static let iso8601Full: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    return formatter
  }()
  
  static let basic: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = .autoupdatingCurrent
    formatter.doesRelativeDateFormatting = true
    formatter.dateStyle = .medium
    return formatter
  }()
}

extension URLRequest {
  func authorized() -> URLRequest {
    var request = self
    request.addValue(StarlingApi.authorization, forHTTPHeaderField: "Authorization")
    return request
  }
}
