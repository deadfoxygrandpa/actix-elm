module Page.WriteArticle exposing (Model, Msg(..), UUID, init, subscriptions, update, view)

import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (..)
import Html.Attributes exposing (class)
import Session
import Style


type alias Model =
    { session : Session.Session
    , uuid : UUID
    }


type alias UUID =
    String


type Msg
    = IDK


init : Session.Session -> UUID -> ( Model, Cmd Msg )
init session uuid =
    Model session uuid |> withNoCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    model |> withNoCmd


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Write Article"
    , content =
        div
            []
            [ text "write an article" ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
