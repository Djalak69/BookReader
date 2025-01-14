import SwiftUI

struct ReadingView: View {
    let bookURL: URL
    
    var body: some View {
        VStack {
            Text("Lecture en cours de développement")
                .font(.title)
                .padding()
            
            Text("URL du livre : \(bookURL.lastPathComponent)")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
} 