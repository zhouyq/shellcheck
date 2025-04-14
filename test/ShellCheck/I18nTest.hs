module ShellCheck.I18nTest (i18nTests) where

import ShellCheck.I18n
import Test.QuickCheck
import Test.Framework
import Test.Framework.Providers.QuickCheck2

i18nTests = testGroup "ShellCheck.I18n" [
    testProperty "英文模式下原始消息不变" $
        \msg -> ioProperty $ do
            setLanguage EN
            return $ translate "1000" msg == msg,
            
    testProperty "中文模式下已翻译消息被替换" $
        \_ -> ioProperty $ do
            setLanguage ZH
            return $ translate "2086" "Use double-quotes..." == "使用双引号防止通配符展开和词分割。",
            
    testProperty "中文模式下未翻译消息保持原样" $
        \msg -> ioProperty $ do
            setLanguage ZH
            return $ translate "9999" msg == msg,
            
    testProperty "语言切换功能有效" $
        \_ -> ioProperty $ do
            setLanguage EN
            en <- currentLanguage
            setLanguage ZH
            zh <- currentLanguage
            return $ en == EN && zh == ZH
  ] 