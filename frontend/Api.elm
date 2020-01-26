module Api exposing (get, hello, login, msgDecoder, post)

import Http
import Json.Decoder exposing (Decoder, field, string)
import Url.Builder


type Endpoint
    = Endpoint String


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
