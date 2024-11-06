import SwiftUI

struct HomeView: View {
    @State private var recipe: String = ""
    @State private var budget: Double = 50
    @State private var selectedTags: [String] = []
    @State private var isLoading = false
    @State private var apiResponse: String? = nil // Holds the API response

    var body: some View {
        if isLoading {
            LoadingView()
        } else if let response = apiResponse {
            ResultView(response: response)
        } else {
            mainContent
        }
    }
    
    var mainContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Que voulez-vous cuisiner ?")
                .font(.headline)
                .padding(.horizontal)
            
            if recipe.isEmpty {
                Text("Entrez le plat pour lequel vous voulez générer votre liste de courses")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
            
            TextEditor(text: $recipe)
                .padding(4)
                .frame(height: 120)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            Text("Pour quel budget ?")
                .font(.headline)
                .padding(.horizontal)
            
            HStack {
                Text("\(Int(budget)) €")
                Slider(value: $budget, in: 0...100)
                    .accentColor(.green)
            }
            .padding(.horizontal)
            
            Text("Des besoin particuliers ?")
                .font(.headline)
                .padding(.horizontal)
            
            TagView(tags: ["SANS NITRITE", "BIO", "SANS GLUTEN", "ANTI-GASPI", "AVEC PROMO", "PROCHE", "PAS CHER", "SANS CONSERVATEURS"], selectedTags: $selectedTags)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: generateShoppingList) {
                Text("Générer ma liste de courses")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color.white)
    }
    
    func generateShoppingList() {
        isLoading = true
        let payload: [String: Any] = [
            "recipe": recipe,
            "budget": Int(budget),
            "tags": selectedTags
        ]
        
        // Here, create JSON body and send the request
        guard let url = URL(string: "http://localhost:3000/api/get_listes") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode JSON
        if let jsonData = try? JSONSerialization.data(withJSONObject: payload) {
            request.httpBody = jsonData
        }
        
        // Perform the request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                if let data = data, let responseString = String(data: data, encoding: .utf8) {
                    self.apiResponse = responseString
                } else {
                    self.apiResponse = "Erreur lors de la génération de la liste de courses."
                }
                self.isLoading = false
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

struct LoadingView: View {
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

struct ResultView: View {
    let response: String
    
    var body: some View {
        ScrollView {
            Text(response)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationBarTitle("Résultat", displayMode: .inline)
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
