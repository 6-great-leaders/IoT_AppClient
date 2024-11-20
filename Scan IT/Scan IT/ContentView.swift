//
//  ContentView.swift
//  Scan IT
//
//  Created by Matteo Boe  on 04/11/2024.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

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
	    .accentColor(.green)
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


struct ScanView: View {
    let urlString = "https://www.google.fr/"
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()

    var body: some View {
        VStack {
            Spacer()

            Text("QR CODE")
                .font(.headline)
                .foregroundColor(.black)
                .padding(.bottom, 20)

            if let qrCodeImage = generateQRCode(from: urlString) {
                Image(uiImage: qrCodeImage)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            } else {
                Text("Impossible de générer le QR code")
                    .foregroundColor(.red)
            }

            Spacer()
        }
        .background(Color(.systemGray6))
        .edgesIgnoringSafeArea(.all)
    }

    func generateQRCode(from string: String) -> UIImage? {
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
}
