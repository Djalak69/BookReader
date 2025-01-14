import SwiftUI

struct CategoryFiltersView: View {
    @Binding var selectedCategory: String?
    
    private let categories = ["Tous", "Fiction", "Non-fiction", "Jeunesse", "Science-fiction", "Romance", "Policier"]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    CategoryButton(
                        title: category,
                        isSelected: selectedCategory == category || (category == "Tous" && selectedCategory == nil)
                    ) {
                        selectedCategory = category == "Tous" ? nil : category
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

private struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    CategoryFiltersView(selectedCategory: .constant("Fiction"))
} 