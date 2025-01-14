import SwiftUI

struct ReaderView: View {
    @StateObject private var viewModel: ReaderViewModel
    @Environment(\.dismiss) private var dismiss
    
    init(book: Book) {
        _viewModel = StateObject(wrappedValue: ReaderViewModel(book: book))
    }
    
    var body: some View {
        ZStack {
            viewModel.theme.backgroundColor
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: viewModel.theme.textColor))
            } else {
                VStack(spacing: 0) {
                    // Barre de navigation personnalisée
                    readerTopBar
                    
                    // Contenu du livre
                    GeometryReader { geometry in
                        HStack(spacing: 0) {
                            // Zone de tap gauche pour page précédente
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(width: geometry.size.width * 0.2)
                                .onTapGesture {
                                    viewModel.previousPage()
                                }
                            
                            // Contenu central
                            ScrollView {
                                Text(viewModel.content)
                                    .font(.system(size: viewModel.fontSize))
                                    .foregroundColor(viewModel.theme.textColor)
                                    .padding()
                                
                                Text("Page \(viewModel.currentPage) sur \(viewModel.totalPages)")
                                    .font(.caption)
                                    .foregroundColor(viewModel.theme.textColor.opacity(0.6))
                            }
                            .frame(width: geometry.size.width * 0.6)
                            
                            // Zone de tap droite pour page suivante
                            Color.clear
                                .contentShape(Rectangle())
                                .frame(width: geometry.size.width * 0.2)
                                .onTapGesture {
                                    viewModel.nextPage()
                                }
                        }
                    }
                    
                    // Barre de progression
                    ProgressView(value: Double(viewModel.currentPage), total: Double(viewModel.totalPages))
                        .padding(.horizontal)
                        .tint(viewModel.theme.textColor)
                }
            }
            
            // Panneau des paramètres
            if viewModel.showSettings {
                readerSettings
            }
        }
        .alert("Erreur", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") {
                viewModel.error = nil
            }
        } message: {
            Text(viewModel.error ?? "")
        }
        .task {
            await viewModel.loadBook()
        }
    }
    
    private var readerTopBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
            }
            
            Spacer()
            
            Text(viewModel.currentChapter)
                .font(.headline)
                .lineLimit(1)
            
            Spacer()
            
            Button {
                viewModel.showSettings.toggle()
            } label: {
                Image(systemName: "textformat.size")
                    .imageScale(.large)
            }
        }
        .foregroundColor(viewModel.theme.textColor)
        .padding()
        .background(viewModel.theme.backgroundColor.opacity(0.9))
    }
    
    private var readerSettings: some View {
        VStack(spacing: 20) {
            Text("Paramètres de lecture")
                .font(.title2)
                .bold()
            
            Divider()
            
            // Taille du texte
            VStack(alignment: .leading) {
                Text("Taille du texte")
                    .font(.headline)
                HStack {
                    Text("A").font(.system(size: 14))
                    Slider(value: .init(
                        get: { viewModel.fontSize },
                        set: { viewModel.updateFontSize($0) }
                    ), in: 12...24)
                    Text("A").font(.system(size: 24))
                }
            }
            
            // Luminosité
            VStack(alignment: .leading) {
                Text("Luminosité")
                    .font(.headline)
                HStack {
                    Image(systemName: "sun.min")
                    Slider(value: .init(
                        get: { viewModel.brightness },
                        set: { viewModel.updateBrightness($0) }
                    ), in: 0...1)
                    Image(systemName: "sun.max")
                }
            }
            
            // Thème
            Button {
                viewModel.toggleTheme()
            } label: {
                HStack {
                    Image(systemName: viewModel.theme == .light ? "moon" : "sun.max")
                    Text(viewModel.theme == .light ? "Mode sombre" : "Mode clair")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(viewModel.theme.backgroundColor)
        .foregroundColor(viewModel.theme.textColor)
        .transition(.move(edge: .bottom))
    }
} 