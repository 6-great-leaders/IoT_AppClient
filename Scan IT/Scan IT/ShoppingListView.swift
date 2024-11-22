import SwiftUI

struct ShoppingListView: View {
    @State private var productQuantities: [Int: Int] = [:] // Quantité par produit
    let products: [Product] // Liste des produits

    var body: some View {
        NavigationView {
            VStack {
                // Liste des produits
                ScrollView {
                    ForEach(products.indices, id: \.self) { index in
                        let product = products[index]

                        HStack(alignment: .top) {
                            // Image du produit
                            AsyncImage(url: URL(string: product.image)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)

                            // Détails du produit
                            VStack(alignment: .leading, spacing: 4) {
                                Text(product.productName)
                                    .font(.headline)

                                Text(product.brand)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)

                                Text("\(product.volume) • \(String(format: "%.2f", product.cost)) €/kg")
                                    .font(.footnote)
                                    .foregroundColor(.gray)

                                if product.AIProposition {
                                    Text("Suggestion : Achat régulier")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .padding(4)
                                        .background(Color(.systemBlue).opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }

                            Spacer()

                            // Contrôle des quantités
                            VStack {
                                Spacer()
                                HStack {
                                    Button(action: {
                                        decreaseQuantity(for: index)
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(.gray)
                                    }

                                    Text("\(productQuantities[index] ?? 1)")
                                        .font(.body)
                                        .padding(.horizontal, 8)

                                    Button(action: {
                                        increaseQuantity(for: index)
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                            .foregroundColor(Color.customGreen)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }

                // Section en bas
                HStack {
                    // Total et Actions
                    HStack {
                        VStack(alignment: .leading) {
                            Text("TOTAL")
                                .font(.headline)
                                .foregroundColor(Color.customGreen)
                            Text("\(calculateTotalCost()) €")
                                .font(.title2)
                                .bold()
                        }
                    }
                    .padding(.horizontal)

                    // Boutons d'actions
                    VStack(spacing: 10) {
                        NavigationLink(destination: ScanView()) {
                            Text("Aller faire mes courses")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.customGreen)
                                .foregroundColor(.white)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.customGreen.opacity(0.3), lineWidth: 10)
                                .padding(.horizontal)
                        )

                        NavigationLink(destination: HomeView()) {
                            Text("Regenerer une liste")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
            }
            .navigationTitle("Liste de courses")
        }.navigationBarBackButtonHidden(true)
    }

    // Méthodes pour gérer les quantités
    private func increaseQuantity(for index: Int) {
        productQuantities[index, default: 1] += 1
    }

    private func decreaseQuantity(for index: Int) {
        if let currentQuantity = productQuantities[index], currentQuantity > 1 {
            productQuantities[index] = currentQuantity - 1
        }
    }

    private func calculateTotalCost() -> String {
        let total = products.enumerated().reduce(0) { total, item in
            let (index, product) = item
            let quantity = productQuantities[index, default: 1]
            return total + (product.cost * Double(quantity))
        }
        return String(format: "%.2f", total)
    }
}

// Exemple de modèle Product
struct Product: Decodable {
    let cost: Double
    let volume: String
    let productName: String
    let brand: String
    let image: String
    let AIProposition: Bool
}
