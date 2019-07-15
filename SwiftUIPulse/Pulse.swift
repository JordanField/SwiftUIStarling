//
//  Pulse.swift
//  SwiftUIPulse
//
//  Created by Jordan Field on 13/07/2019.
//  Copyright © 2019 Jordan Field. All rights reserved.
//

import Foundation
import SwiftUI
import CoreGraphics

extension CGFloat {
  static let tau = 2 * CGFloat.pi
}

struct Ring: View {

  
  var body: some View {
    Text("Ring")
  }
}

struct Pulse: View {
  
  var transactions: [TransactionFeedItem]
  
  var body: some View {
    VStack {
      ForEach(transactions) {transaction in
        Text("1")
      }
    }
  }
}
