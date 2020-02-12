module Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List
import Localization
import Route
import Session
import Style


type Page
    = Other
    | Home
    | Login
    | Register
    | Logout
    | Article
    | WriteArticle


view : Session.Session -> Page -> { title : String, content : Html msg } -> Document msg
view session page { title, content } =
    { title = title
    , body = content :: [ viewFooter ]
    }


viewFooter : Html msg
viewFooter =
    Style.divider
