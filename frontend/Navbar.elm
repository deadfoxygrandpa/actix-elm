module Navbar exposing (Msg(..), view)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List
import Localization
import Route
import Session


type Msg
    = SessionMsg Session.Msg


view : Session.Session -> Html Msg
view session =
    let
        getString =
            Localization.getString (Session.getLanguage session)

        text_ s =
            text <| getString s
    in
    Html.nav
        [ class "flex items-baseline items-center justify-center flex-wrap bg-black p-6"
        , class "text-center text-white"
        ]
        [ h1
            [ class "mx-4 md:mx-24 lg:mx-56 xl:mx-64 w-40"
            , class "font-bold text-3xl tracking-tight"
            ]
            [ text_ "siteName" ]
        , div
            [ class "order-first hidden md:block w-40" ]
            [ a [ class "hover:text-gray-300 mr-2", Route.href Route.Home ] [ text_ "Home" ]
            , span
                [ class "hover:text-gray-300 ml-2 cursor-pointer"
                , onClick (SessionMsg Session.ChangeLanguage)
                ]
                [ text_ "currentLang" ]
            ]
        , div
            [ class "order-last hidden md:block w-40"
            ]
            [ a [ hiddenWhenLoggedIn session, class "hover:text-gray-300 mr-2", Route.href Route.Login ] [ text_ "login" ]
            , a [ hiddenWhenLoggedIn session, class "hover:text-gray-300 ml-2", Route.href Route.Register ] [ text_ "Register" ]
            , a [ hiddenWhenLoggedOut session, class "hover:text-gray-300" ] [ text "Logout" ]
            ]
        ]


hiddenWhenLoggedIn : Session.Session -> Html.Attribute msg
hiddenWhenLoggedIn session =
    class <|
        if Session.loggedIn session then
            "hidden"

        else
            ""


hiddenWhenLoggedOut : Session.Session -> Html.Attribute msg
hiddenWhenLoggedOut session =
    class <|
        if Session.loggedIn session then
            ""

        else
            "hidden"
