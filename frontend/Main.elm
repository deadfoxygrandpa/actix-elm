module Main exposing (main)

import Api
import Browser
import Browser.Navigation exposing (Key)
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (Html, text)
import Html.Attributes
import Http
import Json.Decode exposing (Decoder, field, string)
import Page
import Page.Blank
import Page.Home
import Page.Login
import Page.NotFound
import Page.Register
import Route
import Url exposing (Url)



-- Main


main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }



-- MODEL


type Model
    = Redirect Key
    | NotFound Key
    | Home Key Page.Home.Model
    | Login Key Page.Login.Model
    | Register Key Page.Register.Model


init : Maybe String -> Url -> Key -> ( Model, Cmd Msg )
init _ url key =
    changeRouteTo (Route.fromUrl url) (Redirect key)



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Page.Home.Msg
    | GotLoginMsg Page.Login.Msg
    | GotRegisterMsg Page.Register.Msg


getKey : Model -> Key
getKey model =
    case model of
        Redirect key ->
            key

        NotFound key ->
            key

        Home key _ ->
            key

        Login key _ ->
            key

        Register key _ ->
            key


changeRouteTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        key =
            getKey model
    in
    case maybeRoute of
        Nothing ->
            NotFound key |> withNoCmd

        Just Route.Root ->
            model |> withCmd (Route.replaceUrl key Route.Home)

        Just Route.Logout ->
            model |> withNoCmd

        Just Route.Home ->
            Page.Home.init |> updateWith GotHomeMsg (Home key)

        Just Route.Login ->
            Page.Login.init |> updateWith GotLoginMsg (Login key)

        Just Route.Register ->
            Page.Register.init |> updateWith GotRegisterMsg (Register key)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    model |> withCmd (Browser.Navigation.pushUrl (getKey model) (Url.toString url))

                Browser.External url ->
                    model |> withCmd (Browser.Navigation.load url)

        ( GotHomeMsg subMsg, Home key subModel ) ->
            Page.Home.update subMsg subModel
                |> updateWith GotHomeMsg (Home key)

        ( GotLoginMsg subMsg, Login key subModel ) ->
            Page.Login.update subMsg subModel
                |> updateWith GotLoginMsg (Login key)

        ( GotRegisterMsg subMsg, Register key subModel ) ->
            Page.Register.update subMsg subModel
                |> updateWith GotRegisterMsg (Register key)

        ( _, _ ) ->
            model |> withNoCmd


updateWith : (subMsg -> Msg) -> (subModel -> Model) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toMsg toModel ( subModel, subCmd ) =
    ( toModel subModel, Cmd.map toMsg subCmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound _ ->
            Sub.none

        Redirect _ ->
            Sub.none

        Home _ subModel ->
            Sub.map GotHomeMsg (Page.Home.subscriptions subModel)

        Login _ subModel ->
            Sub.map GotLoginMsg (Page.Login.subscriptions subModel)

        Register _ subModel ->
            Sub.map GotRegisterMsg (Page.Register.subscriptions subModel)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect key ->
            Page.view Page.Other Page.Blank.view

        NotFound key ->
            Page.view Page.Other Page.NotFound.view

        Home key subModel ->
            viewPage Page.Home GotHomeMsg (Page.Home.view subModel)

        Login key subModel ->
            viewPage Page.Login GotLoginMsg (Page.Login.view subModel)

        Register key subModel ->
            viewPage Page.Register GotRegisterMsg (Page.Register.view subModel)
