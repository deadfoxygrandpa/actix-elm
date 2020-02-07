module Main exposing (main)

import Api
import Browser
import Browser.Navigation exposing (Key)
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (Html, text)
import Html.Attributes
import Http
import Json.Decode exposing (Decoder, field, string)
import Localization
import Navbar
import Page
import Page.Article
import Page.Blank
import Page.Home
import Page.Login
import Page.Logout
import Page.NotFound
import Page.Register
import Route
import Session
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
    = Redirect Session.Session
    | NotFound Session.Session
    | Home Page.Home.Model
    | Login Page.Login.Model
    | Logout Page.Logout.Model
    | Register Page.Register.Model
    | Article Page.Article.Model


init : Maybe String -> Url -> Key -> ( Model, Cmd Msg )
init username url key =
    changeRouteTo (Route.fromUrl url) (Redirect <| Session.init key Localization.English username)



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Page.Home.Msg
    | GotLoginMsg Page.Login.Msg
    | GotRegisterMsg Page.Register.Msg
    | GotSessionMsg Session.Msg
    | GotLogoutMsg Page.Logout.Msg
    | GotArticleMsg Page.Article.Msg


getSession : Model -> Session.Session
getSession model =
    case model of
        Redirect session ->
            session

        NotFound session ->
            session

        Home subModel ->
            subModel.session

        Login subModel ->
            subModel.session

        Logout subModel ->
            subModel.session

        Register subModel ->
            subModel.session

        Article subModel ->
            subModel.session


updateSession : Session.Session -> Model -> Model
updateSession session model =
    case model of
        Redirect _ ->
            Redirect session

        NotFound _ ->
            NotFound session

        Home subModel ->
            Home { subModel | session = session }

        Login subModel ->
            Login { subModel | session = session }

        Logout subModel ->
            Logout { subModel | session = session }

        Register subModel ->
            Register { subModel | session = session }

        Article subModel ->
            Article { subModel | session = session }


changeRouteTo : Maybe Route.Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            getSession model
    in
    case maybeRoute of
        Nothing ->
            NotFound session |> withNoCmd

        Just Route.Logout ->
            Page.Logout.init session |> updateWith GotLogoutMsg Logout

        Just Route.Home ->
            Page.Home.init session |> updateWith GotHomeMsg Home

        Just Route.Login ->
            Page.Login.init session |> updateWith GotLoginMsg Login

        Just Route.Register ->
            Page.Register.init session |> updateWith GotRegisterMsg Register

        Just (Route.Article id) ->
            Page.Article.init session id |> updateWith GotArticleMsg Article

        Just Route.Empty ->
            model |> withNoCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    model |> withCmd (Browser.Navigation.pushUrl (model |> getSession |> Session.getKey) (Url.toString url))

                Browser.External url ->
                    model |> withCmd (Browser.Navigation.load url)

        ( GotHomeMsg subMsg, Home subModel ) ->
            Page.Home.update subMsg subModel
                |> updateWith GotHomeMsg Home

        ( GotLoginMsg subMsg, Login subModel ) ->
            Page.Login.update subMsg subModel
                |> updateWith GotLoginMsg Login

        ( GotLogoutMsg subMsg, Logout subModel ) ->
            Page.Logout.update subMsg subModel
                |> updateWith GotLogoutMsg Logout

        ( GotRegisterMsg subMsg, Register subModel ) ->
            Page.Register.update subMsg subModel
                |> updateWith GotRegisterMsg Register

        ( GotArticleMsg subMsg, Article subModel ) ->
            Page.Article.update subMsg subModel
                |> updateWith GotArticleMsg Article

        ( GotSessionMsg Session.ChangeLanguage, _ ) ->
            updateSession (getSession model |> Session.changeLanguage) model |> withNoCmd

        ( GotSessionMsg Session.ChangeMenu, _ ) ->
            updateSession (getSession model |> Session.changeMenu) model |> withNoCmd

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

        Home subModel ->
            Sub.map GotHomeMsg (Page.Home.subscriptions subModel)

        Login subModel ->
            Sub.map GotLoginMsg (Page.Login.subscriptions subModel)

        Logout subModel ->
            Sub.map GotLogoutMsg (Page.Logout.subscriptions subModel)

        Register subModel ->
            Sub.map GotRegisterMsg (Page.Register.subscriptions subModel)

        Article subModel ->
            Sub.map GotArticleMsg (Page.Article.subscriptions subModel)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view (getSession model) page config
            in
            { title = title
            , body = navbar :: List.map (Html.map toMsg) body
            }

        addNavbar document =
            { document | body = navbar :: document.body }

        -- Have to extract Navbar out so it can pass session messages
        navbar : Html Msg
        navbar =
            Html.map navMsg (getSession model |> Navbar.view)

        navMsg msg =
            case msg of
                Navbar.SessionMsg sessionMsg ->
                    GotSessionMsg sessionMsg
    in
    case model of
        Redirect session ->
            Page.view session Page.Other Page.Blank.view

        NotFound session ->
            Page.view session Page.Other Page.NotFound.view |> addNavbar

        Home subModel ->
            viewPage Page.Home GotHomeMsg (Page.Home.view subModel)

        Login subModel ->
            viewPage Page.Login GotLoginMsg (Page.Login.view subModel)

        Logout subModel ->
            viewPage Page.Logout GotLogoutMsg (Page.Logout.view subModel)

        Register subModel ->
            viewPage Page.Register GotRegisterMsg (Page.Register.view subModel)

        Article subModel ->
            viewPage Page.Article GotArticleMsg (Page.Article.view subModel)
