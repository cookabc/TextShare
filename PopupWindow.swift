import Cocoa

class PopupWindow: NSWindow {

    private let imageView = NSImageView()
    private let themeSelector = NSSegmentedControl(labels: ["浅色", "深色", "渐变"], trackingMode: .selectOne, target: nil, action: #selector(themeChanged(_:)))
    private let saveButton = NSButton(title: "保存", target: nil, action: #selector(saveImage))
    private let generator = ImageGenerator()
    private var originalText: String
    private var currentTheme: Theme = .light

    init(image: NSImage, text: String) {
        self.originalText = text

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: min(800, image.size.width + 100), height: image.size.height + 100),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )

        setupWindow()
        setupUI()
        setImage(image)
    }

    private func setupWindow() {
        title = "分享图预览"
        level = .floating
        isMovableByWindowBackground = true
        center()
        minSize = NSSize(width: 400, height: 300)
    }

    private func setupUI() {
        let containerView = NSView()
        contentView?.addSubview(containerView)

        // 图片视图
        containerView.addSubview(imageView)
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.translatesAutoresizingMaskIntoConstraints = false

        // 主题选择器
        containerView.addSubview(themeSelector)
        themeSelector.selectedSegment = 0
        themeSelector.translatesAutoresizingMaskIntoConstraints = false
        themeSelector.target = self

        // 保存按钮
        containerView.addSubview(saveButton)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.target = self

        // 约束
        NSLayoutConstraint.activate([
            // 容器视图
            containerView.leadingAnchor.constraint(equalTo: contentView!.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView!.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: contentView!.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -10),

            // 图片视图
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 600),

            // 主题选择器
            themeSelector.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            themeSelector.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            themeSelector.widthAnchor.constraint(equalToConstant: 200),

            // 保存按钮
            saveButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            saveButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10),
            saveButton.widthAnchor.constraint(equalToConstant: 80)
        ])
    }

    private func setImage(_ image: NSImage) {
        imageView.image = image

        // 调整窗口大小以适应图片
        let imageSize = image.size
        let desiredWidth = min(800, imageSize.width + 40)
        let desiredHeight = imageSize.height + 120

        var frame = self.frame
        frame.size = NSSize(width: desiredWidth, height: desiredHeight)
        self.setFrame(frame, display: true)
    }

    @objc private func themeChanged(_ sender: NSSegmentedControl) {
        switch sender.selectedSegment {
        case 0:
            currentTheme = .light
        case 1:
            currentTheme = .dark
        case 2:
            currentTheme = .gradient
        default:
            currentTheme = .light
        }

        if let newImage = generator.generateImage(from: originalText, theme: currentTheme) {
            setImage(newImage)
            // 更新剪贴板中的图片
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([newImage])
        }
    }

    @objc private func saveImage() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.png]
        savePanel.nameFieldStringValue = "分享图_\(Date().timeIntervalSince1970).png"

        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                if let image = self.imageView.image {
                    _ = self.generator.saveImageToFile(image, to: url)
                }
            }
        }
    }
}