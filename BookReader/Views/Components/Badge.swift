import SwiftUI

struct Badge: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(color)
            .clipShape(Capsule())
    }
}

#Preview {
    HStack {
        Badge(text: "Nouveau", color: .blue)
        Badge(text: "Science-fiction", color: .purple)
    }
    .padding()
} 