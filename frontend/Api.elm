module Api exposing (get, hello, login, post)

import Http
import Url.Builder


type Endpoint
    = Endpoint String


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