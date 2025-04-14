# ShellCheck 中文化项目开发指南

本文档将指导您如何为 ShellCheck 中文化项目设置开发环境，并提供基本的工作流程。

## 开发环境要求

- Git
- Haskell开发工具链 (GHC 8.8+, Cabal 3.0+)
- 构建工具 (make, gcc)
- 文本编辑器或IDE (推荐: VS Code + Haskell插件)

## 环境搭建步骤

### 1. 安装Haskell工具链

#### Ubuntu/Debian

```bash
# 安装GHCup (Haskell工具链管理器)
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# 或直接使用apt
sudo apt-get update
sudo apt-get install -y haskell-platform build-essential
```

#### CentOS/RHEL

```bash
sudo yum install -y epel-release
sudo yum install -y haskell-platform gcc make
```

#### macOS

```bash
brew update
brew install ghc cabal-install stack
```

#### Windows

下载并安装 [GHCup](https://www.haskell.org/ghcup/)，它会帮您安装GHC、Cabal和Stack。

### 2. 获取项目源码

```bash
# 克隆仓库
git clone https://github.com/your-username/shellcheck.git
cd shellcheck

# 切换到中文化分支
git checkout i18n-zh

# 如果分支尚未创建
git checkout -b i18n-zh
```

### 3. 构建项目

```bash
# 更新Cabal包索引
cabal update

# 安装依赖
cabal install --only-dependencies

# 配置项目
cabal configure

# 构建项目
cabal build
```

或者使用Stack构建(可选):

```bash
stack setup
stack build
```

### 4. 运行测试

```bash
# 运行单元测试
cabal test

# 手动测试
cabal run -- shellcheck examples/badfixinline.sh
```

## 开发工作流程

### 1. 确保您在正确的分支上

```bash
git checkout i18n-zh
```

### 2. 保持与上游同步

```bash
# 添加上游仓库(只需做一次)
git remote add upstream https://github.com/koalaman/shellcheck.git

# 获取上游更新
git fetch upstream

# 合并上游更新到您的分支
git merge upstream/master
```

### 3. 实现国际化

关键文件:
- `src/ShellCheck/Analytics.hs` - 包含大多数错误消息
- `src/ShellCheck/AnalyzerLib.hs` - 包含错误消息创建函数
- `src/ShellCheck/Formatter/*.hs` - 包含格式化输出逻辑

### 4. 提交您的更改

```bash
git add .
git commit -m "添加中文国际化支持"
git push origin i18n-zh
```

## 项目结构解析

- `/src/ShellCheck/` - 主要源代码目录
  - `Analytics.hs` - 定义检查规则和错误消息
  - `AnalyzerLib.hs` - 提供分析库函数
  - `AST.hs` - 抽象语法树定义
  - `Parser.hs` - Shell脚本解析器
  - `Formatter/*.hs` - 输出格式化器
  - `Interface.hs` - 公共接口定义

## 国际化开发指南

### 修改makeComment函数

我们需要修改`src/ShellCheck/AnalyzerLib.hs`中的`makeComment`函数，使其支持国际化:

```haskell
-- 原始函数
makeComment :: Severity -> Id -> Code -> String -> TokenComment
makeComment severity id code note =
    newTokenComment {
        tcId = id,
        tcComment = newComment {
            cSeverity = severity,
            cCode = code,
            cMessage = note
        }
    }

-- 修改后的函数(示例)
makeComment :: Severity -> Id -> Code -> String -> TokenComment
makeComment severity id code note =
    newTokenComment {
        tcId = id,
        tcComment = newComment {
            cSeverity = severity,
            cCode = code,
            cMessage = translate (show code) note
        }
    }
```

### 创建国际化模块

创建新文件`src/ShellCheck/I18n.hs`，实现基本的国际化功能:

```haskell
module ShellCheck.I18n where

import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe)

data Language = EN | ZH deriving (Eq, Show)

-- 从环境变量或命令行参数获取语言设置
currentLanguage :: Language
currentLanguage = ZH  -- 默认使用中文，实际应从配置获取

-- 消息ID到中文消息的映射
zhMessages :: Map.Map String String
zhMessages = Map.fromList [
  -- 示例翻译
  ("2086", "使用双引号防止通配符展开和词分割。"),
  ("2154", "引用了变量但未赋值。")
]

-- 翻译函数
translate :: String -> String -> String
translate msgId defaultMsg = 
  case currentLanguage of
    EN -> defaultMsg
    ZH -> fromMaybe defaultMsg (Map.lookup msgId zhMessages)
```

## 常见问题

### 构建失败

- 确保您已安装所有必要的依赖
- 尝试运行`cabal clean`然后重新构建
- 检查GHC和Cabal版本是否兼容

### 测试失败

- 确保您的修改没有破坏现有功能
- 检查错误消息格式是否正确
- 确保翻译后的消息语义保持一致

## 资源

- [Haskell语言文档](https://www.haskell.org/documentation/)
- [ShellCheck Wiki](https://github.com/koalaman/shellcheck/wiki)
- [本项目国际化计划](./project/shellcheck-cn-plan.md)

## 联系方式

如有问题，请通过GitHub Issues联系我们，或直接联系项目负责人。 