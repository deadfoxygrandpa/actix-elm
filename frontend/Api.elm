module Api exposing
    ( LoginInfo
    , UUID
    , article
    , articleSummaryList
    , attemptLogin
    , attemptLogout
    , confirm
    , delay
    , get
    , getArticle
    , hello
    , initLoginInfo
    , login
    , logout
    , msgDecoder
    , post
    , register
    )

import Article
import Http
import Json.Decode exposing (Decoder, field, list, string)
import Json.Encode
import Process
import RemoteData exposing (WebData)
import Task
import Url.Builder


type Endpoint
    = Endpoint String


type alias LoginInfo =
    { username : String
    , password : String
    , reply : Maybe String
    , pageMessage : Maybe String
    , wrongPassword : Bool
    }


type alias UUID =
    String


initLoginInfo : LoginInfo
initLoginInfo =
    { username = ""
    , password = ""
    , reply = Nothing
    , pageMessage = Nothing
    , wrongPassword = False
    }


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


attemptLogout : (Result Http.Error () -> msg) -> Cmd msg
attemptLogout toMsg =
    post
        { endpoint = logout
        , body = Http.emptyBody
        , expect = Http.expectWhatever toMsg
        }


articleSummaryList : (WebData (List Article.ArticleSummary) -> msg) -> Cmd msg
articleSummaryList toMsg =
    get
        { endpoint = articles
        , expect = Http.expectJson (RemoteData.fromResult >> toMsg) (list Article.articleSummaryDecoder)
        }


getArticle : (WebData Article.Article -> msg) -> Int -> Cmd msg
getArticle toMsg id =
    get
        { endpoint = article id
        , expect = Http.expectJson (RemoteData.fromResult >> toMsg) Article.articleDecoder
        }


unwrap : Endpoint -> String
unwrap (Endpoint s) =
    s


url : List String -> Endpoint
url paths =
    Url.Builder.absolute ("api" :: paths) [] |> Endpoint


hello : Endpoint
hello =
    url [ "hello" ]


login : Endpoint
login =
    url [ "login" ]


logout : Endpoint
logout =
    url [ "logout" ]


register : Endpoint
register =
    url [ "register" ]


articles : Endpoint
articles =
    url [ "articles" ]


article : Int -> Endpoint
article id =
    url [ "article", String.fromInt id ]


confirm : String -> String
confirm invitation =
    Url.Builder.absolute [ "api", "confirm", invitation ] []


delay : Float -> msg -> Cmd msg
delay ms msg =
    Task.perform (always msg) (Process.sleep ms)
