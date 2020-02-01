module Localization exposing (Language(..), Text, getChinese, getEnglish, getString, strings, text)

import Dict
import Html


type alias Text =
    { english : String
    , chinese : Maybe String
    }


type Language
    = English
    | Chinese



-- map from name to English / Maybe Chinese


strings : Dict.Dict String Text
strings =
    Dict.fromList
        [ ( "siteName", Text "Rust & Elm" (Just "中文") )
        , ( "login", Text "Sign In" (Just "登录") )
        , ( "currentLang", Text "中文" (Just "En") )
        , ( "Home", Text "Home" (Just "首页") )
        , ( "Register", Text "Register" (Just "注册") )
        , ( "Email Address", Text "Email Address" (Just "邮箱地址") )
        , ( "Password", Text "Password" (Just "密码") )
        , ( "Repeat Password", Text "Repeat Password" (Just "请再次输入密码") )
        ]


getString : Language -> String -> String
getString lang name =
    case Dict.get name strings of
        Nothing ->
            ""

        Just txt ->
            case lang of
                English ->
                    txt.english

                Chinese ->
                    case txt.chinese of
                        Nothing ->
                            txt.english

                        Just s ->
                            s


getEnglish : String -> String
getEnglish =
    getString English


getChinese : String -> String
getChinese =
    getString Chinese


text lang s =
    Html.text <| getString lang s
