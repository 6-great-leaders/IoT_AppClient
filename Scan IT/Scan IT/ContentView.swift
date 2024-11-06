//
//  ContentView.swift
//  Scan IT
//
//  Created by Matteo Boe  on 04/11/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var showSplashScreen = true // State variable to control the splash screen visibility
    
    var body: some View {
        ZStack {
            // Main Tab View content with navigation between "Ma liste" and "La scannette"
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "cart")
                        Text("Ma liste")
                    }
                
                ScanView()
                    .tabItem {
                        Image(systemName: "barcode.viewfinder")
                        Text("La scannette")
                    }
            }
            .opacity(showSplashScreen ? 0 : 1)
            
            
            // Splash Screen
            if showSplashScreen {
                SplashScreen()
                    .transition(.opacity)
                    .onAppear {
                        // Delay for splash screen, then hide it
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            withAnimation {
                                showSplashScreen = false
                            }
                        }
                    }
            }
        }
    }
}

// Splash screen content
struct SplashScreen: View {
    var body: some View {
        VStack {
            Spacer()
            
            Image("ScanITLogo") // Make sure this image is in Assets.xcassets
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            Spacer()
        }
        .background(Color.white)
        .edgesIgnoringSafeArea(.all)
    }
}

// Placeholder for ScanView screen
struct ScanView: View {
    var body: some View {
        Text("La scannette")
            .font(.largeTitle)
    }
}
