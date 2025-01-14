import SwiftUI

struct SubscriptionBannerView: View {
    let remainingDownloads: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Téléchargements restants")
                        .font(.headline)
                    Text("\(remainingDownloads) livres")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // TODO: Action pour l'abonnement premium
                }) {
                    Text("Devenir Premium")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .clipShape(Capsule())
                }
            }
            
            ProgressView(value: Double(remainingDownloads), total: 10)
                .tint(.blue)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    SubscriptionBannerView(remainingDownloads: 7)
        .padding()
        .background(Color(.systemGray6))
} 