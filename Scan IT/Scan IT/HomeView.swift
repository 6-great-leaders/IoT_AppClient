import SwiftUI

extension Color {
    static let customGreen = Color(red: 39/255, green: 194/255, blue: 120/255)
}

struct HomeView: View {
    @State public var _recipe: String = ""
    @State private var budget: Double = 50
    @State private var selectedTags: [String] = []
    @State private var isLoading = false
    @State private var apiResponse: String? = nil // Holds the API response
    @State private var peopleCount = 2
    @State private var products: [Product] = []
    

    var body: some View {
        if isLoading {
            LoadingViewView(recipe: _recipe)
        } else if !products.isEmpty {
            ShoppingListView(products: products)
        } else {
            mainContent
        }
    }
    
    var mainContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Que voulez-vous cuisiner ?")
                .font(.system(size: 24, weight: .semibold))
                .padding(.horizontal)
            
            Text("Entrez le plat pour lequel vous voulez générer votre liste de courses")
                .foregroundColor(.gray)
                .padding(.top, 8)
                .padding(.leading, 5)
                .padding(.horizontal)
            
            TextEditor(text: $_recipe)
                .padding(4)
                .frame(height: 120)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            // nombre de personnes
            HStack {
                Button(action: {
                    if peopleCount > 1 {
                        peopleCount -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(peopleCount > 1 ? .white : .gray)
                        .padding()
                        .frame(width: 40, height: 40)
                        .background(peopleCount > 1 ? Color.customGreen : Color(.systemGray5))
                        .clipShape(Circle())
                }
                .disabled(peopleCount <= 1)
                
                Text(peopleCount == 1 ? "1 personne" : "\(peopleCount) personnes")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.gray)
                
                Button(action: {
                    peopleCount += 1
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 40, height: 40)
                        .background(Color.customGreen)
                        .clipShape(Circle())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 10)
            
            Text("Pour quel budget ?")
                .font(.system(size: 24, weight: .semibold))
                .padding(.horizontal)
            
            HStack {
                Text("\(Int(budget)) €")
                Slider(value: $budget, in: 0...100)
                    .accentColor(.green)
            }
            .padding(.horizontal)
            
            Text("Des besoin particuliers ?")
                .font(.system(size: 24, weight: .semibold))
                .padding(.horizontal)
            
            TagView(tags: ["SANS NITRITE", "BIO", "SANS GLUTEN", "ANTI-GASPI", "AVEC PROMO", "PROCHE", "PAS CHER", "SANS CONSERVATEURS"], selectedTags: $selectedTags)
                .padding(.horizontal)
            
            
            

            Button(action: generateShoppingList) {
                HStack {
                    Image("cierge-magique")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    
                    Text("Générer ma liste de courses")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.customGreen)
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.customGreen.opacity(0.3), lineWidth: 10)
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }.navigationBarBackButtonHidden(true)
    }
    
    func generateShoppingList() {
        isLoading = true
        let payload: [String: Any] = [
            "recipe": _recipe,
            "people": Int(peopleCount),
            "budget": Int(budget),
            "tags": selectedTags
        ]
        
        guard let url = URL(string: "http://localhost:3000/api/shopping-list") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload) {
            request.httpBody = jsonData
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let products = try decoder.decode([Product].self, from: data)
                        self.products = products // Decode and assign products
                        self.isLoading = false
                    } catch {
                        print("Failed to decode JSON: \(error)")
                        self.isLoading = false
                    }
                } else {
                    print("Failed to fetch data: \(error?.localizedDescription ?? "Unknown error")")
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

struct TagView: View {
    let tags: [String]
    @Binding var selectedTags: [String]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(tags.chunked(into: 3), id: \.self) { rowTags in
                HStack(spacing: 10) {
                    ForEach(rowTags, id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 14))
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(selectedTags.contains(tag) ? Color.green : Color(.systemGray5))
                            .foregroundColor(selectedTags.contains(tag) ? .white : .black)
                            .cornerRadius(8)
                            .onTapGesture {
                                toggleSelection(for: tag)
                            }
                    }
                }
            }
        }
    }
    
    private func toggleSelection(for tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.removeAll { $0 == tag }
        } else {
            selectedTags.append(tag)
        }
    }
}

struct LoadingViewView: View {
    var recipe: String = "Texte par défaut"
    @State private var isAnimating = false


    var body: some View {
        VStack {

            Spacer()
            
            Text(recipe)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 60)
            
            
            ZStack {
                Circle()
                    .stroke(Color.green.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.customGreen, lineWidth: 8)
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
                    .onAppear { isAnimating = true }
                
                Image("cierge-magique-vert")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            .padding(.bottom, 20)
            
            Text("Génération en cours...")
                .font(.system(size: 16))
                .foregroundColor(Color.customGreen)
            
            Spacer()
        }
        .background(Color.white)
        .navigationBarBackButtonHidden(true)
    }
}


struct LoadingViewMat: View {
    @State private var loadingMessage = "Merci de patienter, nous sommes entrain de générer un liste de course compatible avec tous vos paramètres"
    @State private var timer: Timer? = nil
    
    var body: some View {
        VStack {
            Spacer()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .green))
                .scaleEffect(2)
                .padding(.vertical, 50)
            
            Text(loadingMessage)
                .foregroundColor(.gray)
                .font(.footnote)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, 20)
            
            Spacer()
        }
        .onAppear {
            startLoadingMessageTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startLoadingMessageTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            if loadingMessage == "Merci de patienter, nous sommes entrain de générer un liste de course compatible avec tous vos paramètres" {
                loadingMessage = "Cette operation peut prendre quelque secondes, merci de patienter"
            } else {
                loadingMessage = "Merci de patienter, nous sommes entrain de générer un liste de course compatible avec tous vos paramètres"
            }
        }
    }
}

// Helper extension to split the array into chunks
extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: self.count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, self.count)])
        }
    }
}
