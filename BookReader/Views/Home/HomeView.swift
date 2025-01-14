import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // En-tête avec profil
                HStack {
                    VStack(alignment: .leading) {
                        if let user = authViewModel.currentUser {
                            Text("Bonjour,")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text(user.username)
                                .font(.title)
                                .bold()
                        }
                    }
                    Spacer()
                    
                    Menu {
                        Button(action: {
                            authViewModel.signOut()
                        }) {
                            Label("Se déconnecter", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                
                // Section Continuer la lecture
                VStack(alignment: .leading, spacing: 15) {
                    Text("Continuer la lecture")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<3) { _ in
                                BookContinueCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Section Les incontournables
                VStack(alignment: .leading, spacing: 15) {
                    Text("Les incontournables")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<5) { _ in
                                BookCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Section Nouveautés
                VStack(alignment: .leading, spacing: 15) {
                    Text("Nouveautés")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(0..<5) { _ in
                                BookCard()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationBarHidden(true)
    }
}

struct BookContinueCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .bottomTrailing) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 280, height: 160)
                
                Text("75%")
                    .font(.caption)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Titre du livre")
                    .font(.headline)
                Text("Auteur")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
    }
}

struct BookCard: View {
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 140, height: 200)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Titre du livre")
                    .font(.headline)
                    .lineLimit(1)
                Text("Auteur")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 140)
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(AuthViewModel())
    }
} 