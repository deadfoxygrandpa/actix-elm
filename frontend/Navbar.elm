module Navbar exposing (Msg(..), view)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Ionicon
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

        open =
            Session.getMenuStatus session

        dropdown =
            if open == Session.Opened then
                True

            else
                False
    in
    Html.nav
        [ class "w-full md:flex items-baseline items-center justify-center flex-wrap bg-black p-6"
        , class <|
            if dropdown then
                "flex-col md:flex-row"

            else
                "flex-row"
        , class "text-center text-white tracking-tighter"
        ]
        [ h1
            [ class "md:mx-24 lg:mx-56 xl:mx-64 w-full md:w-40"
            , class "font-bold text-3xl tracking-tighter select-none relative"
            ]
            [ text_ "siteName"
            , div [ class "md:hidden h-full flex flex-column items-center justify-center absolute inset-y-0 right-0" ] [ hamburger open ]
            ]
        , div
            [ class "md:block md:order-first w-40"
            , class <|
                if dropdown then
                    "block flex flex-col text-right w-full md:w-auto md:text-center"

                else
                    "hidden"
            ]
            [ a [ class "hover:text-gray-300 md:mr-2", Route.href Route.Home ] [ text_ "Home" ]
            , span
                [ class "hover:text-gray-300 md:ml-2 cursor-pointer"
                , onClick (SessionMsg Session.ChangeLanguage)
                ]
                [ text_ "currentLang" ]
            ]
        , div
            [ class "order-last md:flex md:flex-row w-40"
            , class <|
                if dropdown then
                    "block flex flex-col text-right w-full md:w-auto md:text-center"

                else
                    "hidden"
            ]
            [ a [ hiddenWhenLoggedIn session, class "hover:text-gray-300 md:mr-2", Route.href Route.Login ] [ text_ "login" ]
            , a [ hiddenWhenLoggedIn session, class "hover:text-gray-300 md:ml-2", Route.href Route.Register ] [ text_ "Register" ]
            , div [ forAdmin session ]
                [ a [ class "hover:text-gray-300 md:mr-2", Route.href (Route.WriteArticle "0") ] [ text "Create Article" ] ]
            , a [ hiddenWhenLoggedOut session, class "hover:text-gray-300", Route.href Route.Logout ] [ text "Logout" ]
            ]
        ]


type alias RGBA =
    { red : Float
    , green : Float
    , blue : Float
    , alpha : Float
    }


hamburger : Session.MenuStatus -> Html Msg
hamburger menuStatus =
    let
        color =
            RGBA 1 1 1 1

        spin =
            case menuStatus of
                Session.Opened ->
                    class "spin-right"

                Session.Closed ->
                    class "spin-left"

                Session.Init ->
                    class ""
    in
    div
        [ onClick (SessionMsg Session.ChangeMenu), spin ]
        [ Ionicon.plusRound 25 color ]


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


forAdmin : Session.Session -> Html.Attribute msg
forAdmin session =
    class <|
        if Session.isAdmin session then
            ""

        else
            "hidden"
