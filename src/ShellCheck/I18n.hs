{-
    Copyright 2022 ShellCheck-CN Team

    This file is part of ShellCheck.
    https://www.shellcheck.net

    ShellCheck is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    ShellCheck is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
-}

{-# LANGUAGE OverloadedStrings #-}

-- |国际化支持模块，用于实现ShellCheck错误消息的多语言支持。
module ShellCheck.I18n (
    Language(..),
    currentLanguage,
    setLanguage,
    translate
) where

import qualified Data.Map.Strict as Map
import Data.Maybe (fromMaybe)
import System.IO.Unsafe (unsafePerformIO)
import Data.IORef (IORef, newIORef, readIORef, writeIORef)

-- |支持的语言
data Language = EN | ZH 
    deriving (Eq, Show)

-- |全局语言设置，使用IORef以支持在运行时更改
{-# NOINLINE languageRef #-}
languageRef :: IORef Language
languageRef = unsafePerformIO $ newIORef EN

-- |获取当前语言设置
currentLanguage :: Language
currentLanguage = unsafePerformIO $ readIORef languageRef

-- |设置当前语言
setLanguage :: Language -> IO ()
setLanguage = writeIORef languageRef

-- |消息ID到中文消息的映射
zhMessages :: Map.Map String String
zhMessages = Map.fromList [
    -- 基础示例翻译(稍后会扩展)
    ("2086", "使用双引号防止通配符展开和词分割。"),
    ("2034", "变量看起来未被使用。请确认用途(如果在外部使用则导出它)。"),
    ("2154", "引用了变量但未赋值。"),
    ("1012", "未期望的文件结束标记(expected 'fi')。"),
    ("1073", "无法解析此..., 修复前述问题并重试。"),
    ("1009", "前面提到的解析错误是..."),

    -- 控制流相关
    ("2164", "使用 cd ... || exit 而不是 cd ... 或类似结构，以便在cd失败时退出。"),
    ("2015", "不要把花括号用在循环变量名上。"),
    
    -- 引号相关
    ("2016", "用双引号括起表达式表明它不是一个文件名，而是一个参数。"),
    ("2026", "这种写法会在字符串而非变量中查找子字符串。"),
    
    -- 变量相关
    ("2128", "展开没有索引的数组只会返回第一个元素。")
  ]

-- |翻译函数，根据当前语言设置将消息ID转换为相应语言的消息
translate :: String -> String -> String
translate msgId defaultMsg = 
    case unsafePerformIO $ readIORef languageRef of
        EN -> defaultMsg
        ZH -> fromMaybe defaultMsg (Map.lookup msgId zhMessages) 