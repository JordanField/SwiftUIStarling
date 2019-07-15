//
//  ContentView.swift
//  SwiftUIPulse
//
//  Created by Jordan Field on 13/07/2019.
//  Copyright © 2019 Jordan Field. All rights reserved.
//

import SwiftUI
import Combine

class TransactionFeedViewModel: BindableObject {
  
  let account: Account
  @Binding var changesSince: Date {
    didSet {
      self.account.transactionFeedPublisher(since: self.changesSince)
        .collect()
        .assertNoFailure()
        .assign(to: \TransactionFeedViewModel.transactions, on: self)
    }
  }
  
  var didChange = PassthroughSubject<[TransactionFeedItem], Never>()
  
  var transactions = [TransactionFeedItem]() {
    didSet {
      didChange.send(self.transactions)
    }
  }
  
  init(account: Account, changesSince: Binding<Date>) {
    self.$changesSince = changesSince
    self.account = account
  }
}

struct TransactionFeedList: View {
  var account: Account
  
  @State var changesSince: Date = Date()
  @State var transactionsVm: TransactionFeedViewModel = 
  
  var body: some View {
    VStack {
      DatePicker($changesSince)
      List(transactionsVm.transactions) { transaction in
        Text("\(transaction.counterPartyName)")
      }
    }
  }
}

struct ContentView : View {
  
  @State var accounts = [Account]()
  
  func f() {
    accountsPublisher()
      .assertNoFailure()
      .collect()
      .assign(to: \ContentView.accounts, on: self)
  }
  
  var body: some View {
    List(accounts) {account in
      NavigationLink(destination: TransactionFeedList() {
        Text("\(account.currency.rawValue)")
      }
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
