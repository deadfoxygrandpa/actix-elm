module Page exposing (Page(..), view, viewHeader)

import Browser exposing (Document)
import Html exposing (..)
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
    div []
        [ a [ Route.href Route.Home ] [ text "home" ]
        , a [ Route.href Route.Login ] [ text "login" ]
        , a [ Route.href Route.Register ] [ text "register" ]
        ]


viewFooter : Html msg
viewFooter =
    div [] [ text "footer" ]
