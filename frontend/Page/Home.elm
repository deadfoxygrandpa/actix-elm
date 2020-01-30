module Page.Home exposing (Model(..), Msg(..), init, subscriptions, update, view)

import Browser
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (..)


type Model
    = TBC


type Msg
    = TBD


init : ( Model, Cmd Msg )
init =
    ( TBC, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( _, _ ) ->
            model |> withNoCmd


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home"
    , content = div [] [ text "home" ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
