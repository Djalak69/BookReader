import SwiftUI

struct AddBookView: View {
    let fileURL: URL
    let onComplete: (Bool) -> Void
    
    @StateObject private var viewModel = AddBookViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Informations du livre") {
                    TextField("Titre", text: $viewModel.title)
                    TextField("Auteur", text: $viewModel.author)
                    TextField("Description", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                if viewModel.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView("Upload en cours...")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Ajouter un livre")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        Task {
                            let success = await viewModel.uploadBook(fileURL: fileURL)
                            onComplete(success)
                        }
                    }
                    .disabled(viewModel.isLoading || viewModel.title.isEmpty)
                }
            }
            .alert("Erreur", isPresented: $viewModel.showError) {
                Button("OK") { }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    AddBookView(
        fileURL: URL(string: "file:///test.epub")!,
        onComplete: { _ in }
    )
} 