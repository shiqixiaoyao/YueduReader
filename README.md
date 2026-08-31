# 悦读（YueduReader）

一款基于 SwiftUI 和 SwiftData 的中文 iOS 阅读器，支持本地书架、书库搜索、可导入的 JSON 书源，以及自动构建未签名 IPA。

## 构建说明

项目使用 XcodeGen 生成 Xcode 项目。CI 会在 macOS runner 上执行未签名 Release 构建，并将生成的 `YueduReader.unsigned.ipa` 上传到 `ci-latest` 预发布版本。

## 重要说明

`ci-latest` 是持续更新的测试预发布版本，不是正式版本。正式发布需要创建版本标签，例如 `v0.1.0`，并将 Release 设置为非预发布版本。
