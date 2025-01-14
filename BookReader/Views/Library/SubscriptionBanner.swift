import SwiftUI

struct SubscriptionBanner: View {
    let remainingDownloads: Int
    @State private var showSubscriptionDetails = false
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Téléchargements restants")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(remainingDownloads)/3 ce mois-ci")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    showSubscriptionDetails = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            ProgressView(value: Double(3 - remainingDownloads), total: 3.0)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .sheet(isPresented: $showSubscriptionDetails) {
            SubscriptionDetailsView()
        }
    }
}

struct SubscriptionDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Votre Abonnement")
                    .font(.title)
                    .padding(.top)
                
                VStack(alignment: .leading, spacing: 12) {
                    InfoRow(icon: "calendar", title: "Type d'abonnement", value: "Gratuit")
                    InfoRow(icon: "arrow.down.circle", title: "Limite mensuelle", value: "3 téléchargements")
                    InfoRow(icon: "clock", title: "Renouvellement", value: "1er du mois")
                }
                .padding()
                
                Spacer()
                
                Button(action: {
                    // Action pour passer à la version premium
                }) {
                    Text("Passer à la version Premium")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationBarItems(trailing: Button("Fermer") {
                dismiss()
            })
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    SubscriptionBanner(remainingDownloads: 2)
} 