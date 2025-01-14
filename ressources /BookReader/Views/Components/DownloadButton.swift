import SwiftUI

struct DownloadButton: View {
    let isDownloaded: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: isDownloaded ? "checkmark.circle.fill" : "arrow.down.circle")
                .font(.title2)
                .foregroundColor(isDownloaded ? .green : .blue)
        }
        .disabled(isDownloaded)
    }
}

#Preview {
    HStack {
        DownloadButton(isDownloaded: false, action: {})
        DownloadButton(isDownloaded: true, action: {})
    }
    .padding()
} 