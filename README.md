# 项目名称
GostClient

# 简介
GostClient 是一个 iOS 应用程序，旨在提供用户友好的界面和高效的功能，帮助用户管理和访问他们的内容。此应用程序专注于提供流畅的用户体验，支持多种功能，以满足用户的需求。

# 功能
- **用户认证**：安全的登录和注册功能。
- **内容管理**：用户可以轻松管理和组织他们的内容。
- **搜索功能**：快速搜索和过滤内容，以便于访问。
- **通知系统**：实时通知用户关于重要更新和活动。

# 安装
1. 确保您已安装 Xcode。
2. 克隆此仓库：
   ```bash
   git clone https://github.com/novohool/GostClient.git
   ```
3. 打开项目文件 `GostClient.xcodeproj`。
4. 选择目标设备并运行应用程序。
5. 启动应用程序后，确保检查并安装 VPN 描述文件，以便能够正确转发流量。您可以在应用内进行此操作。

# 使用
启动应用程序后，您将看到主界面。您可以通过以下步骤使用应用：
1. 注册或登录您的帐户。
2. 使用内容管理功能来添加、编辑或删除内容。
3. 利用搜索功能快速找到所需内容。
4. 查看通知以获取最新信息。

## 二进制文件下载
在编译过程中，应用程序将自动下载并解压缩 GOST 二进制文件。下载的文件将存储在应用的文档目录中，确保在连接代理之前已经下载成功。

## 二进制管理

在 `BinaryManagementView` 中，用户可以管理 GOST 二进制的安装和运行状态。该视图提供了以下功能：

1. **状态指示器**：
   - **下载中**：当二进制正在下载时，显示蓝色进度指示器。
   - **已安装**：安装成功后，显示绿色勾选图标和状态信息。
   - **未安装**：未安装时，显示红色错误图标和状态信息。

2. **启动和停止代理**：
   - 用户可以通过点击“启动”按钮来启动代理，按钮会变为“停止”以便于用户停止代理运行。

3. **错误处理**：
   - 如果在安装或启动代理时发生错误，用户将看到相应的错误消息，提供更好的反馈。

通过这些功能，用户可以方便地管理 GOST 二进制的运行状态，确保流量的正确转发。

## 目录结构

该项目的目录结构如下：

```
GostClient/
├── Binaries/                # 存放下载的二进制文件
├── GostClient/               # 主应用代码，包含视图和模型
│   ├── ContentView.swift
│   ├── GostClientApp.swift
│   ├── GostViewModel.swift
│   ├── Info.plist
│   ├── Models/              # 数据模型，处理应用逻辑
│   │   ├── ConfigValidator.swift
│   │   ├── GostBinaryManager.swift
│   │   ├── GostLaunchConfig.swift
│   │   ├── LogManager.swift
│   │   ├── ProxyConfig.swift
│   │   └── ProxyRule.swift
│   ├── Views/               # 视图层，管理用户界面
│   │   ├── BinaryManagementView.swift
│   │   ├── ConfigManagementView.swift
│   │   ├── ConfigurationView.swift
│   │   ├── LaunchConfigView.swift
│   │   ├── LogViewer.swift
│   │   ├── ProxyRulesView.swift
│   │   ├── ServerConfigView.swift
│   │   └── TrafficStatsView.swift
│   └── TunnelProvider.swift
├── PacketTunnel/            # VPN 相关代码
├── LICENSE                  # 许可证文件
└── README.md               # 项目说明文件
```

### 目录说明
- **Binaries/**: 存放下载的二进制文件。
- **GostClient/**: 主应用代码，包含所有视图和模型。
- **Models/**: 包含所有数据模型和逻辑处理的文件。
- **Views/**: 包含所有用户界面相关的视图文件。
- **PacketTunnel/**: 包含与 VPN 相关的代码。

### 关键组件
- **GostViewModel**: 负责管理应用的状态和逻辑，包括代理连接和错误处理。
- **BinaryManagementView**: 提供用户界面来管理 GOST 二进制的安装和运行状态。

### 使用说明
要运行此项目，请确保您已安装 Xcode，并按照以下步骤操作：
1. 打开项目文件 `GostClient.xcodeproj`。
2. 选择目标设备并运行应用程序。

通过这些功能，用户可以方便地管理 GOST 二进制的运行状态，确保流量的正确转发。

# 贡献
欢迎贡献！请遵循以下步骤参与：
1. Fork 此仓库。
2. 创建您的功能分支 (`git checkout -b feature/YourFeature`)
3. 提交您的更改 (`git commit -m 'Add some feature'`)
4. 推送到分支 (`git push origin feature/YourFeature`)
5. 创建一个新的 Pull Request。

## 贡献指南
在贡献代码之前，请确保您已经阅读并同意我们的贡献协议。

## 代码风格
请遵循 Swift 代码风格指南，以确保代码的一致性和可读性。

## 提交问题
如果您发现任何错误或有建议，请在 GitHub 上提交问题。感谢您的反馈！

# 技术栈
- Swift
- UIKit
- CoreData
- Alamofire

# 截图
![应用截图](https://example.com/screenshot.png)

# 常见问题解答 (FAQ)
**Q: 如何重置密码？**  
A: 在登录页面点击“忘记密码”，按照提示操作即可。  

**Q: 如何联系支持？**  
A: 请通过 [support@example.com](mailto:support@example.com) 联系我们。  

# 联系方式
如需更多信息，请访问我们的 [官方网站](https://example.com) 或通过电子邮件与我们联系：support@example.com.

# 许可证
此项目采用 MIT 许可证。有关详细信息，请查看 LICENSE 文件.
