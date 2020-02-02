module Page.Home exposing (Model(..), Msg(..), init, subscriptions, update, view)

import Browser
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (..)
import Html.Attributes exposing (class)
import Session exposing (..)


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


view : Model -> Session -> { title : String, content : Html Msg }
view model session =
    { title = "Home"
    , content =
        div
            [ class "container max-w-sm text-center bg-white shadow-md rounded my-4 pt-8 pb-6" ]
            [ if loggedIn session then
                viewLoggedIn (getUsernameUnsafe session)

              else
                viewLoggedOut
            ]
    }


viewLoggedIn : String -> Html msg
viewLoggedIn username =
    div
        [ class "" ]
        [ text <| "Hello, " ++ username ]


viewLoggedOut : Html msg
viewLoggedOut =
    div
        [ class "" ]
        [ text "You are not logged in." ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


x : Html msg
x =
    div
        [ class "whatever" ]
        []
