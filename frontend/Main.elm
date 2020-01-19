module Main exposing (..)

import Browser
import Html exposing (Html, text)
import Http
import Json.Decode exposing (Decoder, field, string)

-- Main

main =
  Browser.element
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- MODEL


type Model
  = Failure
  | Loading
  | Success String

init : () -> (Model, Cmd Msg)
init _ =
  ( Loading
  , Http.get
      { url = "api/hello"
      , expect = Http.expectJson GotJson msgDecoder
      }
  )


-- UPDATE


msgDecoder : Decoder String
msgDecoder =
  field "msg" string

type Msg
  = GotJson (Result Http.Error String)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GotJson result ->
      case result of
        Ok s ->
          (Success s, Cmd.none)

        Err _ ->
          (Failure, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none



-- VIEW


view : Model -> Html Msg
view model =
  case model of
    Failure ->
      text "couldn't contact the api"

    Loading ->
      text "loading..."

    Success s ->
       text s 
