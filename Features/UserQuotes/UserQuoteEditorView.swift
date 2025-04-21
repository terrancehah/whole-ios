// UserQuoteEditorView.swift
// UI for creating and editing user-generated quotes.
// This view allows premium users to submit bilingual quotes with category selection.
// UI follows Serene Minimalism: soft backgrounds, clear input fields, and pastel accent buttons.

import SwiftUI

/// A semantic, aesthetic editor for creating user-generated quotes.
struct UserQuoteEditorView: View {
    /// English quote input
    @State private var englishText: String = ""
    /// Chinese translation input
    @State private var chineseText: String = ""
    /// Selected categories (from QuoteCategory enum)
    @State private var selectedCategories: Set<QuoteCategory> = []
    /// All available categories
    let allCategories: [QuoteCategory]
    /// Submission state
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String?
    /// Dismiss action (for modal)
    var onDismiss: (() -> Void)? = nil

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    Text("Create a New Quote")
                        .font(.largeTitle).bold()
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)

                    // English input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("English Text")
                            .font(.headline)
                        TextField("Enter the quote in English", text: $englishText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocapitalization(.sentences)
                    }

                    // Chinese input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chinese Translation")
                            .font(.headline)
                        TextField("输入中文翻译", text: $chineseText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }

                    // Category selection
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Categories")
                            .font(.headline)
                        // Show as chips
                        WrapHStack(spacing: 8) {
                            ForEach(allCategories, id: \ .self) { category in
                                CategoryChip(
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
                    }

                    // Error message
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.subheadline)
                    }

                    // Submit button
                    CustomButton(
                        label: isSubmitting ? "Submitting..." : "Submit Quote",
                        systemImage: "paperplane.fill",
                        action: submitQuote,
                        color: .accentColor,
                        isDisabled: isSubmitting || !canSubmit
                    )
                    .padding(.top, 12)

                    // Success message
                    if showSuccess {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                            Text("Quote submitted for review!")
                                .foregroundColor(.green)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { onDismiss?() }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }

    /// Whether the form can be submitted (basic validation)
    private var canSubmit: Bool {
        !englishText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !chineseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedCategories.isEmpty
    }

    /// Handles quote submission logic
    private func submitQuote() {
        guard canSubmit else { return }
        isSubmitting = true
        errorMessage = nil
        showSuccess = false
        // Simulate network submission (replace with real backend call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isSubmitting = false
            showSuccess = true
            // Optionally reset fields or dismiss
            englishText = ""
            chineseText = ""
            selectedCategories.removeAll()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showSuccess = false
                onDismiss?()
            }
        }
    }
}

// MARK: - Category Chip
/// A pastel, rounded chip for category selection.
struct CategoryChip: View {
    let category: QuoteCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(category.displayName)
            .font(.caption)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.25) : Color(.systemGray5))
            .foregroundColor(isSelected ? .accentColor : .secondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: 1)
            )
            .onTapGesture(perform: onTap)
    }
}

// MARK: - WrapHStack
/// A utility view to wrap chips to the next line if needed.
struct WrapHStack<Content: View>: View {
    let spacing: CGFloat
    let content: () -> Content
    init(spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.content = content
    }
    var body: some View {
        FlexibleView(
            availableWidth: UIScreen.main.bounds.width - 48,
            spacing: spacing,
            alignment: .leading,
            content: content
        )
    }
}

// MARK: - FlexibleView (for wrapping chips)
/// A generic flexible layout for wrapping chips (copied from community best practices)
struct FlexibleView<Content: View>: View {
    let availableWidth: CGFloat
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: () -> Content
    init(availableWidth: CGFloat, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping () -> Content) {
        self.availableWidth = availableWidth
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }
    var body: some View {
        let content = self.content()
        return _FlexibleView(availableWidth: availableWidth, spacing: spacing, alignment: alignment, content: content)
    }
}

private struct _FlexibleView<Content: View>: View {
    let availableWidth: CGFloat
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: Content
    @State private var totalHeight: CGFloat = .zero
    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            GeometryReader { geometry in
                self.generateContent(in: geometry)
            }
        }
        .frame(height: totalHeight)
    }
    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var rows: [[Content]] = [[]]
        let contentViews = Mirror(reflecting: content).children.compactMap { $0.value as? Content }
        var currentRow: [Content] = []
        for view in contentViews {
            let viewWidth = view.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: .greatestFiniteMagnitude)).width
            if width + viewWidth + spacing > availableWidth {
                rows.append(currentRow)
                currentRow = [view]
                width = viewWidth + spacing
            } else {
                currentRow.append(view)
                width += viewWidth + spacing
            }
        }
        if !currentRow.isEmpty { rows.append(currentRow) }
        return VStack(alignment: alignment, spacing: spacing) {
            ForEach(0..<rows.count, id: \ .self) { rowIndex in
                HStack(spacing: spacing) {
                    ForEach(0..<rows[rowIndex].count, id: \ .self) { colIndex in
                        rows[rowIndex][colIndex]
                    }
                }
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: FlexibleViewHeightKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(FlexibleViewHeightKey.self) { height in
            self.totalHeight = height
        }
    }
}

private struct FlexibleViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
