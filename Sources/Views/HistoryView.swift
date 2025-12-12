import SwiftUI
import ComposableArchitecture

// MARK: - History View
// Modern SwiftUI features: collection views, animations, search

struct HistoryView: View {
    let store: StoreOf<HistoryFeature.State>

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 0) {
                // Header with search
                headerSection(viewStore: viewStore)

                Divider()

                // History Items
                if viewStore.items.isEmpty {
                    emptyStateView()
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
    @ObservedObject var viewStore: ViewStoreOf<HistoryFeature.State>
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
                ForEach(HistoryFeature.State.Filter.allCases, id: \.self) { filter in
                    filterTab(
                        filter: filter,
                        isSelected: viewStore.currentFilter == filter,
                        count: viewStore.filteredItems(for: filter).count
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
    let filter: HistoryFeature.State.Filter
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
private struct emptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 64))
                .foregroundColor(.tertiary)

            Text("暂无历史记录")
                .font(.title2)
                .fontWeight(.medium)

            Text("生成的图片将会显示在这里")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.controlBackgroundColor))
    }
}

// MARK: - History Items Grid
private struct historyItemsGrid: View {
    @ObservedObject var viewStore: ViewStoreOf<HistoryFeature.State>
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

    private var filteredItems: [HistoryFeature.State.HistoryItem] {
        let items = viewStore.filteredItems(for: viewStore.currentFilter)

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
    let item: HistoryFeature.State.HistoryItem
    @ObservedObject var viewStore: ViewStoreOf<HistoryFeature.State>
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
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.controlBackgroundColor))
                .frame(height: 160)

            if let image = NSImage(data: imageData) {
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .shadow(radius: 2)
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundColor(.tertiary)
                    Text("图片加载失败")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func actionsRow(item: HistoryFeature.State.HistoryItem) -> some View {
        HStack {
            Button("重新生成") {
                viewStore.send(.regenerateFromItem(item))
            }
            .buttonStyle(.borderless)
            .font(.caption)

            Spacer()

            Button("删除") {
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
    private func isSearchMatch(for item: HistoryFeature.State.HistoryItem, searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        return item.text.localizedCaseInsensitiveContains(searchText)
    }
}

// MARK: - Preview
#Preview {
    HistoryView(
        store: Store(initialState: HistoryFeature.State()) {
            HistoryFeature()
        }
    )
}