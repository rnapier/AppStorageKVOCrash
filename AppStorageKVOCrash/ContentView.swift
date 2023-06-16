//
//  ContentView.swift
//  AppStorageKVOCrash
//
//  Created by Napier, Rob on 6/14/23.
//

import SwiftUI

struct ContentView: View {
    @State var n: Int = 0

    // This song-and-dance is to make sure that AppStorageView is destroyed and recreated.
    // The two views are visually identical to make the output easier to read. One has @AppStorage,
    // the other does not. This causes very fast registering/deregistering from UserDefaults KVO.
    func bodyView() -> AnyView {
        if n % 2 == 0 {
            return AnyView(
                ForEach(0..<10) { _ in
                    AppStorageView(n: n)
                })
        } else {
            return AnyView(
                ForEach(0..<10) { _ in
                    NoAppStorageView(n: n)
                })
        }
    }

    var body: some View {
        bodyView()
            .task {
                // Churn UserDefaults on a background thread.
                Task.detached {
                    while true {
                        UserDefaults.standard.set(Date(), forKey: "randomOtherUserDefaultsKey")
                        await Task.yield()
                    }
                }

                // At the same time, churn the Views to create and destroy AppStorage observations.
                while true {
                    n += 1
                    await Task.yield()
                }
            }
    }
}

// View with @AppStorage observation
struct AppStorageView: View {
    var n: Int

    @AppStorage("appStorageValue") var appStorageValue = false

    var body: some View { LogView(n: n) }
}

// View without @AppStorage observation
struct NoAppStorageView: View {
    var n: Int

    var body: some View { LogView(n: n) }
}

struct LogView: View {
    var n: Int
    var body: some View {
        HStack {
            Text("App Storage Test: \(n)")
            Spacer()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
