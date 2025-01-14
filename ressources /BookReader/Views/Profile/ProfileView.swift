import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .padding()
            
            Text("Nom d'utilisateur")
                .font(.title)
            
            List {
                Section(header: Text("Informations")) {
                    HStack {
                        Text("Email")
                        Spacer()
                        Text("utilisateur@example.com")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Livres lus")
                        Spacer()
                        Text("0")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
} 