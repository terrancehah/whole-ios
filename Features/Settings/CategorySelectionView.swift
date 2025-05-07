// CategorySelectionView.swift
// UI for selecting preferred quote categories in settings or onboarding.

import SwiftUI

/// A reusable category selection grid for onboarding and settings.
struct CategorySelectionView: View {
    @Binding var selectedCategories: Set<QuoteCategory>
    let allCategories: [QuoteCategory]
    let onSave: (() -> Void)? // Optional save handler for settings

    let columns = [GridItem(.adaptive(minimum: 120), spacing: 16)]

    var body: some View {
        VStack(spacing: 24) {
            Text("Select Your Preferred Categories")
                .headingFont(size: 22)
                .padding(.top)
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(allCategories, id: \ .self) { category in
                    CategoryGridItemSetting(
                        category: category,
                        isSelected: selectedCategories.contains(category),
                        onTap: {
                            if selectedCategories.contains(category) {
                                selectedCategories.remove(category)
                            } else {
                                selectedCategories.insert(category)
                            }
                        }
                    )
                }
            }
            .padding(.vertical)
            if let onSave = onSave {
                Button("Save", action: onSave)
                    .buttonStyle(WarmPrimaryButtonStyle())
                    .disabled(selectedCategories.isEmpty)
            }
        }
        .padding(.horizontal)
    }
}

/// Individual category grid item for display and selection.
/// CategoryGridItemSetting is used only in Settings. It avoids conflict with Onboarding's CategoryGridItem.
struct CategoryGridItemSetting: View {
    let category: QuoteCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(category.displayName)
                .bodyFont()
                .padding()
                .frame(maxWidth: .infinity)
                // Match onboarding: orange background and white text when selected
                .background(isSelected ? Color(hex: "#ff9f68") : Color.white)
                .cornerRadius(12)
                .foregroundColor(isSelected ? Color.white : Color.primary)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color(hex: "#ff9f68") : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
                )
        }
        .animation(.easeInOut, value: isSelected)
    }
}
