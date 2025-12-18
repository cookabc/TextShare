import SwiftUI
import ComposableArchitecture

// MARK: - History View
// Modern SwiftUI features: collection views, animations, search

struct HistoryView: View {
    let store: StoreOf<HistoryFeature>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Header with search
                headerSection(viewStore: viewStore)

                Divider()

                // History Items
                if viewStore.items.isEmpty {
                    historyEmptyStateView()
                } else {
                    historyItemsGrid(viewStore: viewStore)
                }
            }
            .background(Color(.controlBackgroundColor))
            .frame(minWidth: 600, minHeight: 500)
        }
    }
}

// MARK: - Header Section
private struct headerSection: View {
    @ObservedObject var viewStore: ViewStoreOf<HistoryFeature>
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("历史记录")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()

                HStack(spacing: 12) {
                    // Search
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("搜索历史记录...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.textBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color(.separatorColor), lineWidth: 1)
                            )
                    )
                    .frame(maxWidth: 200)

                    // Clear All Button
                    Button("清空全部") {
                        viewStore.send(.clearAll)
                    }
                    .buttonStyle(.bordered)
                    .disabled(viewStore.items.isEmpty)
                }
            }

            // Filter Tabs
            HStack(spacing: 0) {
                ForEach(HistoryFeature.Filter.allCases, id: \.self) { filter in
                    filterTab(
                        filter: filter,
                        isSelected: viewStore.currentFilter == filter,
                        count: 0
                    ) {
                        viewStore.send(.setFilter(filter))
                    }
                }
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.textBackgroundColor))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color(.separatorColor), lineWidth: 1)
                    )
            )
        }
        .padding(24)
        .padding(.bottom, 16)
    }
}

// MARK: - Filter Tab
private struct filterTab: View {
    let filter: HistoryFeature.Filter
    let isSelected: Bool
    let count: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: filter.iconName)
                    .font(.caption)
                Text(filter.localizedName)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                if count > 0 {
                    Text("(\(count))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            )
            .foregroundColor(isSelected ? .accentColor : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State View
private struct historyEmptyStateView: View {
    var body: some View {
        EmptyStateView(
            icon: "clock.arrow.circlepath",
            title: NSLocalizedString("history_empty_title", comment: ""),
            description: NSLocalizedString("history_empty_desc", comment: "")
        )
        .background(Color(.controlBackgroundColor))
    }
}

// MARK: - History Items Grid
private struct historyItemsGrid: View {
    @ObservedObject var viewStore: ViewStoreOf<HistoryFeature>
    @State private var searchText = ""

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 280), spacing: 16)
            ], spacing: 16) {
                ForEach(filteredItems) { item in
                    historyItemCard(item: item, viewStore: viewStore)
                }
            }
            .padding(24)
        }
    }

    private var filteredItems: [HistoryFeature.HistoryItem] {
        let items = viewStore.items.map { HistoryFeature.HistoryItem(from: $0) }

        if searchText.isEmpty {
            return items
        } else {
            return items.filter { item in
                item.text.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

// MARK: - History Item Card
private struct historyItemCard: View {
    let item: HistoryFeature.HistoryItem
    @ObservedObject var viewStore: ViewStoreOf<HistoryFeature>
    @State private var isHovered = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Preview
            imagePreview(imageData: item.imageData)

            // Text Content
            VStack(alignment: .leading, spacing: 4) {
                Text(item.text)
                    .font(.body)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                Text(formattedDate(item.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Actions
            actionsRow(item: item)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.textBackgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isHovered ? Color.accentColor : Color(.separatorColor),
                            lineWidth: isHovered ? 2 : 1
                        )
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }

    private func imagePreview(imageData: Data) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md)
                .fill(Color(.controlBackgroundColor))
                .frame(height: 160)
            
            AsyncImageDataView(imageData: imageData, contentMode: .fit)
                .frame(maxHeight: 140)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .shadow(color: DesignTokens.Shadow.light, radius: 2)
        }
    }

    private func actionsRow(item: HistoryFeature.HistoryItem) -> some View {
        HStack {
            Button(NSLocalizedString("regenerate", comment: "")) {
                viewStore.send(.regenerateFromItem(item.toHistoryItemData))
            }
            .buttonStyle(.borderless)
            .font(.caption)

            Spacer()

            Button(NSLocalizedString("delete", comment: "")) {
                viewStore.send(.removeItem(item.id))
            }
            .buttonStyle(.borderless)
            .font(.caption)
            .foregroundColor(.red)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - History View Extensions
extension HistoryView {
    // Helper methods for search and filtering
    private func isSearchMatch(for item: HistoryFeature.HistoryItem, searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        return item.text.localizedCaseInsensitiveContains(searchText)
    }
}

// MARK: - Preview
// MARK: - Preview
// #Preview temporarily removed due to macro compilation issues