//
//  ContentView.swift
//  myMiniZoo
//
//  Created by Nadia Putri Natali Lubis on 18/07/26.
//

import SwiftUI
import RealityKit


struct ARViewContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ViewController {
        return ViewController()
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {
    }
}
struct ContentView : View {

    var body: some View {
        ARViewContainer()
        .edgesIgnoringSafeArea(.all)
    }

}

#Preview {
    ContentView()
}
