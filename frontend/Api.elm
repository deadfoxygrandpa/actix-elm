module Api exposing (LoginInfo, attemptLogin, confirm, get, hello, initLoginInfo, login, msgDecoder, post, register)

import Http
import Json.Decode exposing (Decoder, field, string)
import Json.Encode
import Url.Builder


type Endpoint
    = Endpoint String


type alias LoginInfo =
    { username : String
    , password : String
    , reply : Maybe String
    , wrongPassword : Bool
    }


initLoginInfo : LoginInfo
initLoginInfo =
    { username = "", password = "", reply = Nothing, wrongPassword = False }


encodeLoginInfo : LoginInfo -> Json.Encode.Value
encodeLoginInfo form =
    let
        username =
            form.username |> String.toLower |> String.trim
    in
    Json.Encode.object
        [ ( "username", Json.Encode.string username )
        , ( "password", Json.Encode.string form.password )
        ]


msgDecoder : Decoder String
msgDecoder =
    field "msg" string


get :
    { endpoint : Endpoint
    , expect : Http.Expect msg
    }
    -> Cmd msg
get config =
    Http.get { url = unwrap config.endpoint, expect = config.expect }


post :
    { endpoint : Endpoint
    , body : Http.Body
    , expect : Http.Expect msg
    }
    -> Cmd msg
post config =
    Http.post { url = unwrap config.endpoint, body = config.body, expect = config.expect }


attemptLogin : LoginInfo -> (Result Http.Error String -> msg) -> Cmd msg
attemptLogin loginInfo toMsg =
    post
        { endpoint = login
        , body = Http.jsonBody <| encodeLoginInfo loginInfo
        , expect = Http.expectJson toMsg msgDecoder
        }


unwrap : Endpoint -> String
unwrap (Endpoint s) =
    s


url : List String -> Endpoint
url paths =
    Url.Builder.relative ("api" :: paths) [] |> Endpoint


hello : Endpoint
hello =
    url [ "hello" ]


login : Endpoint
login =
    url [ "login" ]


register : Endpoint
register =
    url [ "register" ]


confirm : String -> String
confirm invitation =
    Url.Builder.relative [ "api", "confirm", invitation ] []
