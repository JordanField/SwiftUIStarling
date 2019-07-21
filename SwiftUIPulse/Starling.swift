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

enum StarlingApi {
  static let apiUrl = URL(string: "https://api.starlingbank.com/api/")!
  static let authorization = "Bearer \(accessToken)"
  
  enum Accounts {
    struct ListResource: Decodable {
        var accounts: [Account]
    }
    
    static func list() -> URLRequest {
      let url = URL(string: "v2/accounts", relativeTo: apiUrl)!
      return URLRequest(url: url).authorized()
    }
  }
  
  enum TransactionFeed {
    struct ListResource: Decodable {
      var feedItems: [TransactionFeedItem]
    }
    
    static func list(account: Account, changesSince: Date) -> URLRequest {
      let formatter = ISO8601DateFormatter()
      let url = URL(string: "v2/feed/account/\(account.id)/category/\(account.defaultCategory)?changesSince=\(formatter.string(from: changesSince))", relativeTo: StarlingApi.apiUrl)!
      return URLRequest(url: url).authorized()
    }
  }
}

extension Array {
  var publisher: Publishers.Sequence<Self, Error> { Publishers.Sequence(sequence: self) }
}

enum Currency: String, Codable {
  case GBP, EUR
}

enum Direction: String, Codable {
  case IN, OUT
}

struct Money: Codable, CustomStringConvertible {
  var currency: String
  var minorUnits: Int
  
  var decimal: String {
    return "\(minorUnits / 100).\(minorUnits % 100)"
  }
  
  var description: String { "\(currency) \(decimal)" }
}

class Account: Identifiable, Decodable {
  let accountUid: UUID
  let defaultCategory: UUID
  let currency: Currency
  let createdAt: String
  
  var id: UUID { accountUid }
  
  lazy var transactionFeed = TransactionFeed(account: self)
}

class TransactionFeed: BindableObject {
  let account: Account
  var feed: [TransactionFeedItem] = [] { didSet { didChange.send() } }
  let didChange = PassthroughSubject<Void, Never>()
  
  private func getFeed() {
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601Full)
    
    _ = URLSession.shared.dataTaskPublisher(for: StarlingApi.TransactionFeed.list(account: account, changesSince: Date(timeIntervalSince1970: 0)))
      .validateHttpUrlResponse()
      .map { (data, _) in data}
      .decode(type: StarlingApi.TransactionFeed.ListResource.self, decoder: decoder)
      .map { $0.feedItems }
      .catch { _ in Just([]) }
      .receive(on: RunLoop.main)
      .sink { self.feed = $0 }
  }
  
  init(account: Account) {
    self.account = account
    print("new transaction feed")
    
    self.getFeed()
  }
}

class AccountsListViewModel: BindableObject {
  var accounts: [Account] = []
  var didChange = URLSession.shared.dataTaskPublisher(for: StarlingApi.Accounts.list())
    .validateHttpUrlResponse()
    .map { (data, _) in data }
    .decode(type: StarlingApi.Accounts.ListResource.self, decoder: JSONDecoder()).print()
    .map { $0.accounts }
    .catch { error in Just([]) }
    .receive(on: RunLoop.main)
  
  init() {
    _ = didChange.assign(to: \.accounts, on: self)
  }
}

struct TransactionFeedItem: Identifiable, Decodable {
  var feedItemUid: UUID
  var categoryUid: UUID
  var amount: Money
  var sourceAmount: Money
  var direction: Direction
  var counterPartyName: String
  var status: String
  var transactionTime: Date
    
  typealias Id = UUID
  var id: UUID { feedItemUid }
}

class TransactionFeedViewModel: BindableObject {
  let account: Account
  @Published var changesSince = Date()
  var feed: [TransactionFeedItem] = []
  
  lazy var didChange = self.$changesSince.print()
    .flatMap { date in
      URLSession.shared.dataTaskPublisher(for: StarlingApi.TransactionFeed.list(account: self.account, changesSince: date))
      .assertNoFailure()
    }
    .validateHttpUrlResponse()
    .map { (data, _) in data }
    .decode(type: StarlingApi.TransactionFeed.ListResource.self, decoder: JSONDecoder())
    .map { $0.feedItems }
    .catch { _ in Just([]) }
    .receive(on: RunLoop.main)
  
  init(account: Account) {
    self.account = account
    _ = self.didChange.assign(to: \.feed, on: self)
  }
}
  
enum NetworkError: Error {
  case responseNotHttp
  case statusCode(Int)
}
