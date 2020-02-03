module Route exposing (Route(..), fromUrl, href, load, replaceToHome, replaceUrl)

import Browser.Navigation exposing (Key)
import Html exposing (Attribute)
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s, string)


type Route
    = Root
    | Logout
    | Home
    | Login
    | Register
    | Empty


fromUrl : Url -> Maybe Route
fromUrl url =
    case url.path of
        "/" ->
            Just Home

        "/logout" ->
            Just Logout

        "/index" ->
            Just Home

        "/login" ->
            Just Login

        "/register" ->
            Just Register

        _ ->
            Nothing


replaceUrl : Key -> Route -> Cmd msg
replaceUrl key route =
    Browser.Navigation.replaceUrl key (routeToString route)


replaceToHome : Key -> Cmd msg
replaceToHome key =
    replaceUrl key Home


routeToString : Route -> String
routeToString route =
    case route of
        Root ->
            "/"

        Logout ->
            "/logout"

        Home ->
            "/"

        Login ->
            "/login"

        Register ->
            "/register"

        Empty ->
            ""


href : Route -> Attribute msg
href route =
    Html.Attributes.href (routeToString route)


load : Route -> Cmd msg
load route =
    Browser.Navigation.load <| routeToString route
