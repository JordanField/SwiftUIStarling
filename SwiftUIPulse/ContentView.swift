//
//  ContentView.swift
//  SwiftUIPulse
//
//  Created by Jordan Field on 13/07/2019.
//  Copyright © 2019 Jordan Field. All rights reserved.
//

import SwiftUI
import Combine
import Foundation


struct TransactionFeedDetail: View {
  let transactionFeedItem: TransactionFeedItem
  
  var body: some View {
    VStack {
      Text(verbatim: "\(transactionFeedItem.id)")
      Text(verbatim: "\(transactionFeedItem.counterPartyName)")
      Text(verbatim: "\(transactionFeedItem.amount.description)")
      Text("\(transactionFeedItem.transactionTime)")
    }.navigationBarTitle(Text(verbatim: "\(transactionFeedItem.counterPartyName)"))
  }
}

struct TransactionFeedList: View {
  let account: Account
  
  @State private var changesSince: Date = Date()
  @State private var transactions: [TransactionFeedItem] = []
  
  private func pub() -> AnyPublisher<[TransactionFeedItem], Never> {
    return account.transactionFeedPublisher(since: Date(timeIntervalSince1970: 0))
      .collect()
      .catch { _ in Just([]) }
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
  
  init(account: Account) {
    self.account = account
  }
  
  var body: some View {
    List(transactions) { transaction in
      PresentationLink(destination: TransactionFeedDetail(transactionFeedItem: transaction)) {
        HStack {
          Text("\(transaction.counterPartyName)")
          Spacer()
          Text("\(transaction.sourceAmount.description)")
        }
      }
    }.navigationBarTitle("\(account.currency.rawValue)")
     .onReceive(pub()) {
      self.transactions = $0
    }
  }
}

struct ContentView : View {
  
  @State var accounts = [Account]()
  
  private let publisher =
    accountsPublisher()
      .collect()
      .catch { _ in Just([]) }
      .receive(on: RunLoop.main)
  
  var body: some View {
    VStack {
      NavigationView {
        List(accounts) {account in
          NavigationLink(destination: TransactionFeedList(account: account)) {
            Text(verbatim: "\(account.currency.rawValue)")
          }
        }.navigationBarTitle(Text("Accounts"), displayMode: .inline)
      }
    }.onReceive(publisher) {
      self.accounts = $0
    }
  }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
