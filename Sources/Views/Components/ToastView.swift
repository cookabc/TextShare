import SwiftUI

// MARK: - Toast Notification System
// A modern toast system for showing feedback to users

// MARK: - Toast Type
enum ToastType {
    case success
    case error
    case info
    case warning
    
    var icon: String {
        switch self {
        case .success: return "checkmark.circle.fill"
        case .error: return "xmark.circle.fill"
        case .info: return "info.circle.fill"
        case .warning: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .success: return .green
        case .error: return .red
        case .info: return .blue
        case .warning: return .orange
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success: return .green.opacity(0.1)
        case .error: return .red.opacity(0.1)
        case .info: return .blue.opacity(0.1)
        case .warning: return .orange.opacity(0.1)
        }
    }
}

// MARK: - Toast Data
struct ToastData: Equatable, Identifiable {
    let id: UUID
    let message: String
    let type: ToastType
    let duration: TimeInterval
    
    init(id: UUID = UUID(), message: String, type: ToastType, duration: TimeInterval = 3.0) {
        self.id = id
        self.message = message
        self.type = type
        self.duration = duration
    }
    
    static func success(_ message: String) -> ToastData {
        ToastData(message: message, type: .success)
    }
    
    static func error(_ message: String) -> ToastData {
        ToastData(message: message, type: .error, duration: 5.0)
    }
    
    static func info(_ message: String) -> ToastData {
        ToastData(message: message, type: .info)
    }
    
    static func warning(_ message: String) -> ToastData {
        ToastData(message: message, type: .warning, duration: 4.0)
    }
}

// MARK: - Toast View
struct ToastView: View {
    let toast: ToastData
    let onDismiss: () -> Void
    
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: toast.type.icon)
                .foregroundColor(toast.type.color)
                .font(.system(size: 18, weight: .semibold))
            
            Text(toast.message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            Spacer(minLength: 8)
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss notification")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(toast.type.color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
        .frame(maxWidth: 400)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : -20)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(toast.type) notification: \(toast.message)")
    }
}

// MARK: - Toast Container View
struct ToastContainerView<Content: View>: View {
    @Binding var toast: ToastData?
    let content: Content
    
    init(toast: Binding<ToastData?>, @ViewBuilder content: () -> Content) {
        self._toast = toast
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            content
            
            if let toast = toast {
                VStack {
                    ToastView(toast: toast) {
                        dismissToast()
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
                .onAppear {
                    scheduleAutoDismiss(duration: toast.duration)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: toast?.id)
    }
    
    private func dismissToast() {
        withAnimation {
            toast = nil
        }
    }
    
    private func scheduleAutoDismiss(duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            dismissToast()
        }
    }
}

// MARK: - View Extension for Toast
extension View {
    func toast(_ toast: Binding<ToastData?>) -> some View {
        ToastContainerView(toast: toast) {
            self
        }
    }
}

// MARK: - Preview
#if DEBUG
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            ToastView(toast: .success("Image generated successfully!")) {}
            ToastView(toast: .error("Failed to export image")) {}
            ToastView(toast: .info("Copied to clipboard")) {}
            ToastView(toast: .warning("Large file size detected")) {}
        }
        .padding(50)
        .background(Color.gray.opacity(0.1))
    }
}
#endif
