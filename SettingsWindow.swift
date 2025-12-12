import Cocoa

class SettingsWindow: NSWindow {
    private let fontConfig = FontConfig.shared

    // UI 元素
    private var fontFamilyPopup: NSPopUpButton!
    private var fontSizePopup: NSPopUpButton!
    private var paddingSlider: NSSlider!
    private var paddingLabel: NSTextField!
    private var maxWidthSlider: NSSlider!
    private var maxWidthLabel: NSTextField!
    private var watermarkField: NSTextField!
    private var previewImageView: NSImageView!
    private var previewButton: NSButton!

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 500, height: 400), styleMask: [.titled, .closable], backing: backingStoreType, defer: flag)

        self.title = "设置"
        self.isReleasedWhenClosed = false
        setupUI()
        loadConfig()
        generatePreview()
    }

    private func setupUI() {
        let mainView = NSView()
        contentView = mainView

        // 创建设置界面
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 20
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false

        // 字体选择
        let fontSection = createFontSection()
        stackView.addArrangedSubview(fontSection)

        // 尺寸设置
        let sizeSection = createSizeSection()
        stackView.addArrangedSubview(sizeSection)

        // 水印设置
        let watermarkSection = createWatermarkSection()
        stackView.addArrangedSubview(watermarkSection)

        // 预览区域
        let previewSection = createPreviewSection()
        stackView.addArrangedSubview(previewSection)

        mainView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: mainView.bottomAnchor, constant: -20)
        ])
    }

    private func createFontSection() -> NSView {
        let containerView = NSView()
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 10

        // 标题
        let titleLabel = NSTextField(labelWithString: "字体设置")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        stackView.addArrangedSubview(titleLabel)

        // 字体族选择
        let fontRow = NSStackView()
        fontRow.orientation = .horizontal
        fontRow.spacing = 10
        fontRow.alignment = .centerY

        let fontLabel = NSTextField(labelWithString: "字体：")
        fontFamilyPopup = NSPopUpButton()
        FontConfig.FontFamily.allCases.forEach { family in
            fontFamilyPopup.addItem(withTitle: family.displayName)
        }

        fontRow.addArrangedSubview(fontLabel)
        fontRow.addArrangedSubview(fontFamilyPopup)
        fontRow.addArrangedSubview(NSView())

        stackView.addArrangedSubview(fontRow)

        // 字体大小选择
        let sizeRow = NSStackView()
        sizeRow.orientation = .horizontal
        sizeRow.spacing = 10
        sizeRow.alignment = .centerY

        let sizeLabel = NSTextField(labelWithString: "大小：")
        fontSizePopup = NSPopUpButton()
        FontConfig.FontSize.allCases.forEach { size in
            fontSizePopup.addItem(withTitle: "\(size.displayName) (\(Int(size.rawValue))pt)")
        }

        sizeRow.addArrangedSubview(sizeLabel)
        sizeRow.addArrangedSubview(fontSizePopup)
        sizeRow.addArrangedSubview(NSView())

        stackView.addArrangedSubview(sizeRow)

        // 连接事件
        fontFamilyPopup.target = self
        fontFamilyPopup.action = #selector(configChanged)
        fontSizePopup.target = self
        fontSizePopup.action = #selector(configChanged)

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createSizeSection() -> NSView {
        let containerView = NSView()
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 10

        // 标题
        let titleLabel = NSTextField(labelWithString: "尺寸设置")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        stackView.addArrangedSubview(titleLabel)

        // 内边距
        let paddingRow = NSStackView()
        paddingRow.orientation = .horizontal
        paddingRow.spacing = 10
        paddingRow.alignment = .centerY

        let paddingLabel = NSTextField(labelWithString: "内边距：")
        self.paddingSlider = NSSlider(value: 40, minValue: 20, maxValue: 60, target: self, action: #selector(sliderChanged))
        self.paddingLabel = NSTextField(labelWithString: "40px")

        paddingRow.addArrangedSubview(paddingLabel)
        paddingRow.addArrangedSubview(paddingSlider)
        paddingRow.addArrangedSubview(self.paddingLabel)

        // 最大宽度
        let maxWidthRow = NSStackView()
        maxWidthRow.orientation = .horizontal
        maxWidthRow.spacing = 10
        maxWidthRow.alignment = .centerY

        let maxWidthLabel = NSTextField(labelWithString: "最大宽度：")
        self.maxWidthSlider = NSSlider(value: 600, minValue: 400, maxValue: 800, target: self, action: #selector(sliderChanged))
        self.maxWidthLabel = NSTextField(labelWithString: "600px")

        maxWidthRow.addArrangedSubview(maxWidthLabel)
        maxWidthRow.addArrangedSubview(self.maxWidthSlider)
        maxWidthRow.addArrangedSubview(self.maxWidthLabel)

        // 连接事件
        paddingSlider.target = self
        paddingSlider.action = #selector(sliderChanged)
        maxWidthSlider.target = self
        maxWidthSlider.action = #selector(sliderChanged)

        stackView.addArrangedSubview(paddingRow)
        stackView.addArrangedSubview(maxWidthRow)

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createWatermarkSection() -> NSView {
        let containerView = NSView()
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 10

        // 标题
        let titleLabel = NSTextField(labelWithString: "水印设置")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)
        stackView.addArrangedSubview(titleLabel)

        // 水印输入
        watermarkField = NSTextField()
        watermarkField.placeholderString = "可选：添加水印文本"
        watermarkField.target = self
        watermarkField.action = #selector(configChanged)

        stackView.addArrangedSubview(watermarkField)

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    private func createPreviewSection() -> NSView {
        let containerView = NSView()
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 10

        // 标题和按钮
        let headerRow = NSStackView()
        headerRow.orientation = .horizontal
        headerRow.spacing = 10
        headerRow.alignment = .centerY

        let titleLabel = NSTextField(labelWithString: "预览")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 16)

        previewButton = NSButton(title: "生成预览", target: self, action: #selector(generatePreview))

        headerRow.addArrangedSubview(titleLabel)
        headerRow.addArrangedSubview(NSView())
        headerRow.addArrangedSubview(previewButton)

        // 预览图片
        previewImageView = NSImageView()
        previewImageView.imageFrameStyle = .none
        previewImageView.wantsLayer = true
        previewImageView.layer?.borderWidth = 1
        previewImageView.layer?.borderColor = NSColor.controlAccentColor.cgColor
        previewImageView.layer?.cornerRadius = 8

        stackView.addArrangedSubview(headerRow)
        stackView.addArrangedSubview(previewImageView)

        containerView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            previewImageView.heightAnchor.constraint(equalToConstant: 150)
        ])

        return containerView
    }

    @objc private func configChanged() {
        generatePreview()
    }

    @objc private func sliderChanged() {
        let paddingValue = Int(paddingSlider.doubleValue)
        let maxWidthValue = Int(maxWidthSlider.doubleValue)
        paddingLabel.stringValue = "\(paddingValue)px"
        maxWidthLabel.stringValue = "\(maxWidthValue)px"
        generatePreview()
    }

    @objc private func generatePreview() {
        let config = getConfigFromUI()
        let previewText = "字体预览\nHello World! 你好世界！\nThe quick brown fox jumps over the lazy dog."

        // 使用更新后的 ImageGenerator 生成预览
        let generator = ImageGenerator.shared
        let image = generator.generateImage(from: previewText, theme: .light, config: config)

        previewImageView.image = image
    }

    private func getConfigFromUI() -> FontConfig.ExportConfig {
        let selectedFamilyIndex = fontFamilyPopup.indexOfSelectedItem
        let selectedSizeIndex = fontSizePopup.indexOfSelectedItem

        return FontConfig.ExportConfig(
            fontFamily: FontConfig.FontFamily.allCases[selectedFamilyIndex],
            fontSize: FontConfig.FontSize.allCases[selectedSizeIndex],
            padding: paddingSlider.doubleValue,
            maxWidth: maxWidthSlider.doubleValue,
            lineHeight: 1.4,
            watermark: watermarkField.stringValue.isEmpty ? nil : watermarkField.stringValue
        )
    }

    private func loadConfig() {
        let config = fontConfig.getCurrentConfig()

        // 设置字体族
        if let index = FontConfig.FontFamily.allCases.firstIndex(of: config.fontFamily) {
            fontFamilyPopup.selectItem(at: index)
        }

        // 设置字体大小
        if let index = FontConfig.FontSize.allCases.firstIndex(of: config.fontSize) {
            fontSizePopup.selectItem(at: index)
        }

        // 设置滑块值
        paddingSlider.doubleValue = config.padding
        maxWidthSlider.doubleValue = config.maxWidth
        paddingLabel.stringValue = "\(Int(config.padding))px"
        maxWidthLabel.stringValue = "\(Int(config.maxWidth))px"

        // 设置水印
        if let watermark = config.watermark {
            watermarkField.stringValue = watermark
        }
    }

    override func close() {
        saveConfig()
        super.close()
    }

    private func saveConfig() {
        fontConfig.updateConfig(getConfigFromUI())
    }
}