module Main exposing (main)

import Api
import Browser
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (Html, text)
import Html.Attributes
import Http
import Json.Decode exposing (Decoder, field, string)
import Page.Login



-- Main


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { hello : Hello
    , login : Page.Login.Model
    }


type Hello
    = Failure
    | Loading
    | Success String


init : () -> ( Model, Cmd Msg )
init _ =
    ( { hello = Loading, login = Page.Login.init }
    , Api.get
        { endpoint = Api.hello
        , expect = Http.expectJson GotJson msgDecoder
        }
    )



-- UPDATE


msgDecoder : Decoder String
msgDecoder =
    field "msg" string


type Msg
    = GotJson (Result Http.Error String)
    | LoginMsg Page.Login.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotJson result ->
            case result of
                Ok s ->
                    ( { model | hello = Success s }, Cmd.none )

                Err _ ->
                    ( { model | hello = Failure }, Cmd.none )

        LoginMsg loginMsg ->
            updateWith LoginMsg (\m -> { model | login = m }) (Page.Login.update loginMsg model.login)


updateWith : (subMsg -> Msg) -> (subModel -> Model) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toMsg toModel ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ viewAPIResult model.hello
        , Html.map LoginMsg (Page.Login.view model.login)
        ]


viewAPIResult : Hello -> Html msg
viewAPIResult model =
    case model of
        Failure ->
            text "couldn't contact the api"

        Loading ->
            text "loading..."

        Success s ->
            text s
