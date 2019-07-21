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

struct BlurVisualEffect: UIViewRepresentable {
  let style: UIBlurEffect.Style
  
  func makeUIView(context: UIViewRepresentableContext<BlurVisualEffect>) -> UIView {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clear
    let blurEffect = UIBlurEffect(style: style)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.translatesAutoresizingMaskIntoConstraints = false
    view.insertSubview(blurView, at: 0)
    NSLayoutConstraint.activate([
      blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
      blurView.widthAnchor.constraint(equalTo: view.widthAnchor)
    ])
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BlurVisualEffect>) {}
}

extension TimeInterval {
  static func minutes(_ n: Double) -> TimeInterval { n * 60.0 }
  static func hours(_ n: Double)   -> TimeInterval { n * minutes(60.0) }
  static func days(_ n: Double)    -> TimeInterval { n * hours(24.0) }
}

struct TransactionFeedList: View {
  @ObjectBinding var feed: TransactionFeed
  @Binding var changesSince: Date
  
  var body: some View {
    List(feed.feed.filter { $0.transactionTime < changesSince }) { item in
      HStack {
        Text("\(item.transactionTime, formatter: DateFormatter.basic)").bold()
        Spacer()
        Text(verbatim: "\(item.sourceAmount.description)")
      }
    }
  }
}

struct TransactionFeedOverview: View {
  let account: Account
  @ObjectBinding var feed: TransactionFeed
  @State private var open = false
  @State private var dragOffset = CGSize.zero
  @State private var changesSince: Date = Date()
  
  var body: some View {
    ZStack {
      TransactionFeedList(feed: feed, changesSince: $changesSince)
      VStack {
        Spacer()
        ZStack {
          ShapeView(shape: Rectangle(), style: Color.white)
            .frame(maxHeight: 250)
            .cornerRadius(40).shadow(radius: 10)
          VStack {
            ShapeView(shape: Capsule(), style: Color.secondary).frame(width: 30, height: 5, alignment: .center).gesture(DragGesture().onChanged { value in
              self.dragOffset = value.translation
            })
            DatePicker($changesSince)
          }
        }.offset(y: dragOffset.height)
      }.edgesIgnoringSafeArea(.bottom)
    }.navigationBarTitle("\(account.currency.rawValue)", displayMode: .inline)
  }
}

struct ContentView : View {
  
  @State var accounts = [Account]()
  @ObjectBinding var viewModel = AccountsListViewModel()
  
  var body: some View {
    NavigationView {
      List(viewModel.accounts) { account in
        NavigationLink(destination: TransactionFeedOverview(account: account, feed: account.transactionFeed)) {
          Text(verbatim: "\(account.currency.rawValue)")
        }.environmentObject(TransactionFeed(account: account))
      }.navigationBarTitle("Accounts")
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
