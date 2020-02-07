module Route exposing (Route(..), fromUrl, href, load, pushUrl, replaceToHome, replaceUrl)

import Browser.Navigation exposing (Key)
import Html exposing (Attribute)
import Html.Attributes
import Process
import Task
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, string)


type Route
    = Logout
    | Home
    | Login
    | Register
    | Article Int
    | Empty


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Logout (s "logout")
        , Parser.map Home (s "index")
        , Parser.map Login (s "login")
        , Parser.map Register (s "register")
        , Parser.map Article (s "article" </> int)
        ]


replaceUrl : Key -> Route -> Cmd msg
replaceUrl key route =
    Browser.Navigation.replaceUrl key (routeToString route)


pushUrl : Key -> Route -> Cmd msg
pushUrl key route =
    Browser.Navigation.pushUrl key (routeToString route)


replaceToHome : Key -> Cmd msg
replaceToHome key =
    replaceUrl key Home


routeToString : Route -> String
routeToString route =
    case route of
        Logout ->
            "/logout"

        Home ->
            "/"

        Login ->
            "/login"

        Register ->
            "/register"

        Article id ->
            "/article/" ++ String.fromInt id

        Empty ->
            ""


href : Route -> Attribute msg
href route =
    Html.Attributes.href (routeToString route)


load : Route -> Cmd msg
load route =
    Browser.Navigation.load <| routeToString route
