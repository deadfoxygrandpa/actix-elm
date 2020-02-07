module Page.Article exposing (Model, Msg(..), init, subscriptions, update, view)

import Api
import Article
import Browser
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (..)
import Html.Attributes exposing (class)
import Http
import RemoteData
import Route
import Session exposing (..)
import Style


type alias Model =
    { article : RemoteData.WebData Article.Article
    , session : Session
    }


type Msg
    = GetArticle (RemoteData.WebData Article.Article)


init : Session -> Int -> ( Model, Cmd Msg )
init session id =
    ( { article = RemoteData.NotAsked, session = session }, Api.getArticle GetArticle id )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetArticle response ->
            { model | article = response } |> withNoCmd


view : Model -> { title : String, content : Html Msg }
view model =
    let
        response =
            model.article

        title =
            case model.article of
                RemoteData.Success article ->
                    article.headlineCN

                RemoteData.Failure _ ->
                    "Error"

                _ ->
                    "Loading"

        session =
            model.session
    in
    { title = title
    , content =
        Html.div
            [ class "w-full md:grid md:grid-cols-4 md:gap-4" ]
        <|
            case response of
                RemoteData.Failure _ ->
                    [ Html.div [ class "md:col-start-2 md:col-span-2 m4 md:m-0 flex flex-row justify-center text-center" ] [ text "Failed" ] ]

                RemoteData.Success article ->
                    [ viewArticle article
                    ]

                _ ->
                    [ Html.div [ class "md:col-start-2 md:col-span-2 m4 md:m-0 flex flex-row justify-center" ] [ Style.loadingIcon ] ]
    }


viewArticle : Article.Article -> Html msg
viewArticle article =
    Html.div
        [ class "md:col-start-2 md:col-span-2 m-4 md:m-0 md:mt-4" ]
        [ h1 [ class "w-full text-center text-3xl font-bold" ] [ text article.headlineCN ]
        , h3 [ class "text-sm text-center md:text-left" ] [ text article.author ]
        , h3 [ class "text-xs text-center md:text-left" ] [ text <| Article.timeToDate article.dateCreated ]
        , Style.divider
        , div
            [ class "w-full h-48 bg-fixed"
            , Style.maybeBackgroundImage article.image
            ]
            []
        , p [] [ text article.articleBody ]
        , p [] [ text article.articleBody ]
        , p [] [ text article.articleBody ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
