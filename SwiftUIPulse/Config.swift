//
//  config.swift
//  SwiftUIPulse
//
//  Created by Jordan Field on 13/07/2019.
//  Copyright © 2019 Jordan Field. All rights reserved.
//

import Foundation

let authorization = "Bearer \(accessToken)"
let apiUrl = URL(string: "https://api.starlingbank.com/api/")!

extension URLRequest {
  func authorized() -> URLRequest {
    var request = self
    request.addValue(authorization, forHTTPHeaderField: "Authorization")
    return request
  }
}
