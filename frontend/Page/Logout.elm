module Page.Logout exposing (Model, Msg(..), Status(..), init, subscriptions, update, view)

import Api
import Browser
import Browser.Navigation
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (..)
import Html.Attributes exposing (class, for, href, id, placeholder, type_)
import Html.Events
import Http
import Json.Encode
import Localization
import Route
import Session
import Style


type alias Model =
    { session : Session.Session
    , loggedOut : Status
    }


type Status
    = Requested
    | Done


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = LogOut (Result Http.Error ())
    | LoggedOut


init : Session.Session -> ( Model, Cmd Msg )
init session =
    { session = session
    , loggedOut = Requested
    }
        |> (if not (Session.loggedIn session) then
                withCmd (Route.replaceUrl (Session.getKey session) Route.Home)

            else
                withCmd (Api.attemptLogout LogOut)
           )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LogOut _ ->
            { model | loggedOut = Done } |> withCmd (Api.delay 5000 LoggedOut)

        LoggedOut ->
            model |> withCmd (Route.load Route.Home)


view : Model -> { title : String, content : Html Msg }
view model =
    let
        msg =
            case model.loggedOut of
                Requested ->
                    "Logging out."

                Done ->
                    "You have been logged out. Redirecting to the home page."
    in
    { title = "Logout"
    , content = text msg |> Style.bodyAlert
    }
