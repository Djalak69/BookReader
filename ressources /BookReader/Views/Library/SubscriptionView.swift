import SwiftUI

struct SubscriptionView: View {
    let content: String
    let publisher: String
    let action: () -> Void
    
    init(content: String, publisher: String, action: @escaping () -> Void) {
        self.content = content
        self.publisher = publisher
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Abonnement Premium")
                .font(.title)
                .bold()
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 16) {
                SubscriptionFeature(
                    icon: "infinity",
                    title: "Téléchargements illimités",
                    description: "Accédez à tous les livres sans restriction"
                )
                
                SubscriptionFeature(
                    icon: "book.closed",
                    title: "Contenu exclusif",
                    description: content
                )
                
                SubscriptionFeature(
                    icon: "building.2",
                    title: "Éditeur partenaire",
                    description: publisher
                )
                
                SubscriptionFeature(
                    icon: "iphone.and.arrow.forward",
                    title: "Multi-appareils",
                    description: "Synchronisation sur tous vos appareils"
                )
            }
            .padding()
            
            Spacer()
            
            VStack(spacing: 12) {
                Button(action: action) {
                    Text("S'abonner maintenant")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Text("14,99 € / mois")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
    }
}

struct SubscriptionFeature: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

#Preview {
    SubscriptionView(
        content: "Accédez à des livres exclusifs et des avant-premières",
        publisher: "En partenariat avec les plus grands éditeurs",
        action: {}
    )
} 