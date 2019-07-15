//
//  Starling.swift
//  SwiftUIPulse
//
//  Created by Jordan Field on 13/07/2019.
//  Copyright © 2019 Jordan Field. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

extension Array {
  var publisher: Publishers.Sequence<Self, Error> { Publishers.Sequence(sequence: self) }
}

enum Currency: String, Codable {
  case GBP, EUR
}

enum Direction: String, Codable {
  case IN, OUT
}

struct Money: Codable {
  var currency: String
  var minorUnits: Int
}

struct Account: Identifiable, Decodable {
  var accountUid: UUID
  var defaultCategory: UUID
  var currency: Currency
  var createdAt: String
  
  typealias Id = UUID
  var id: UUID { accountUid }
}

struct AccountsResource: Decodable {
  var accounts: [Account]
}

struct TransactionFeedItem: Identifiable, Decodable {
  var feedItemUid: UUID
  var categoryUid: UUID
  var amount: Money
  var sourceAmount: Money
  var direction: Direction
  var counterPartyName: String
    
  typealias Id = UUID
  var id: UUID { feedItemUid }
}
  
struct ListTransactionFeedResource: Decodable {
  var feedItems: [TransactionFeedItem]
}
  
enum NetworkError: Error {
  case responseNotHttp
  case statusCode(Int)
}

let jsonDecoder = JSONDecoder()
let jsonEncoder = JSONEncoder()
  
func accountsPublisher() -> AnyPublisher<Account, Error> {
  
  let url = URL(string: "v2/accounts", relativeTo: apiUrl)!
  let request = URLRequest(url: url).authorized()
  
  return URLSession.shared.dataTaskPublisher(for: request)
    .validateHttpUrlResponse()
    .map { (data, _) in data }
    .decode(type: AccountsResource.self, decoder: jsonDecoder)
    .map { resource in resource.accounts }
    .flatMap { accounts in accounts.publisher().setFailureType(to: Error.self) }
    .eraseToAnyPublisher()
}

extension Account {
 
    func transactionFeedPublisher(since date: Date) -> AnyPublisher<TransactionFeedItem, Error> {
    
    let formatter = ISO8601DateFormatter()
    
    let url = URL(string: "v2/feed/account/\(self.id)/category/\(self.defaultCategory)?changesSince=\(formatter.string(from: date))", relativeTo: apiUrl)!
    var request = URLRequest(url: url).authorized()
    
    return URLSession.shared.dataTaskPublisher(for: request)
      .validateHttpUrlResponse()
      .map { (data, _ ) in data }
      .decode(type: ListTransactionFeedResource.self, decoder: jsonDecoder)
      .map { $0.feedItems }
      .flatMap { $0.publisher().setFailureType(to: Error.self) }
      .eraseToAnyPublisher()
  }
}
