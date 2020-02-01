module Page exposing (Page(..), view, viewHeader)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import List
import Route


type Page
    = Other
    | Home
    | Login
    | Register


view : Page -> { title : String, content : Html msg } -> Document msg
view page { title, content } =
    { title = title
    , body = viewHeader :: content :: [ viewFooter ]
    }


viewHeader : Html msg
viewHeader =
    viewNavbar2



--div []
--    [ a [ Route.href Route.Home ] [ text "home" ]
--    , a [ Route.href Route.Login ] [ text "login" ]
--    , a [ Route.href Route.Register ] [ text "register" ]
--    ]


viewNavbar2 =
    nav
        [ class "flex items-baseline items-center justify-center flex-wrap bg-black p-6"
        , class "text-center text-white"
        ]
        [ h1
            [ class "mx-4 md:mx-24 lg:mx-56 xl:mx-64"
            , class "font-bold text-3xl tracking-tight"
            ]
            [ text "Rust & Elm" ]
        , div
            [ class "order-first hidden md:block w-40" ]
            [ a [ class "hover:text-gray-300", Route.href Route.Home ] [ text "Home" ] ]
        , div
            [ class "order-last hidden md:block w-40" ]
            [ a [ class "hover:text-gray-300 mr-2", Route.href Route.Login ] [ text "Sign In" ]
            , a [ class "hover:text-gray-300 ml-2", Route.href Route.Register ] [ text "Register" ]
            ]
        ]



--viewNavbar =
--    nav [ class "flex items-center justify-between flex-wrap bg-black p-6" ]
--        [ div [ class "flex items-center flex-shrink-0 text-white mr-6" ]
--            [ span [ class "font-bold text-xl tracking-tight" ]
--                [ text "Read Chinese" ]
--            ]
--        , div [ class "block lg:hidden" ]
--            [ button [ class "flex items-center px-3 py-2 border rounded text-teal-200 border-teal-400 hover:text-white hover:border-white" ] [ text "X" ]
--            ]
--        , div [ class "w-full block flex-grow lg:flex lg:items-center lg:w-auto" ]
--            [ div [ class "text-sm lg:flex-grow" ]
--                [ a [ class "block mt-4 lg:inline-block lg:mt-0 text-teal-200 hover:text-white hover:border mr-4", Route.href Route.Home ]
--                    [ text "Home      " ]
--                , a [ class "block mt-4 lg:inline-block lg:mt-0 text-teal-200 hover:text-white mr-4", Route.href Route.Login ]
--                    [ text "Login      " ]
--                , a [ class "block mt-4 lg:inline-block lg:mt-0 text-teal-200 hover:text-white", Route.href Route.Register ]
--                    [ text "Register      " ]
--                ]
--            , div []
--                [ a [ class "inline-block text-sm px-4 py-2 leading-none border rounded text-white border-white hover:border-transparent hover:text-teal-500 hover:bg-white mt-4 lg:mt-0", href "#" ]
--                    [ text "Something here" ]
--                ]
--            ]
--        ]


viewFooter : Html msg
viewFooter =
    div [ class "container text-center" ] [ text "footer" ]
