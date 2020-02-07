module Page.Home exposing (Model, Msg(..), init, subscriptions, update, view)

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
    { articles : RemoteData.WebData (List Article.ArticleSummary)
    , session : Session
    }


type Msg
    = GetArticleSummaries (RemoteData.WebData (List Article.ArticleSummary))
    | Article Route.Route


init : Session -> ( Model, Cmd Msg )
init session =
    ( { articles = RemoteData.NotAsked, session = session }, Api.articleSummaryList GetArticleSummaries )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GetArticleSummaries response ->
            { model | articles = response } |> withNoCmd

        Article id ->
            model |> withCmd (Route.pushUrl (Session.getKey model.session) id)


view : Model -> { title : String, content : Html Msg }
view model =
    let
        response =
            model.articles

        session =
            model.session
    in
    { title = "Home"
    , content =
        Html.div
            []
            [ splash
            , Html.div
                [ class "w-full md:grid md:grid-cols-4 md:gap-4" ]
              <|
                case response of
                    RemoteData.Failure _ ->
                        [ Html.div [ class "md:col-start-2 md:col-span-2 m4 md:m-0 flex flex-row justify-center text-center" ] [ text "Failed" ] ]

                    RemoteData.Success articles ->
                        List.map
                            (\article ->
                                Html.div
                                    [ class "md:col-start-2 md:col-span-2 m-4 md:m-0" ]
                                    [ Article.articleSummaryCard Article article ]
                            )
                            articles

                    _ ->
                        [ Html.div [ class "md:col-start-2 md:col-span-2 m4 md:m-0 flex flex-row justify-center" ] [ Style.loadingIcon ] ]
            ]
    }


splash : Html msg
splash =
    Html.div
        [ class "gradient px-3 pt-24 pb-24 mx-auto items-center"
        , class "text-black font-bold"
        , class "fade-in"
        ]
        [ Html.div
            [ class "container text-center md:text-left w-full flex flex-wrap flex-col md:flex-row items-center" ]
            [ --left column
              Html.div
                [ class "w-full md:w-1/2 px-6" ]
                [ h2
                    [ class "mb-4"
                    , class "text-5xl tracking-tight"
                    ]
                    [ text "Learn to read Chinese" ]
                , h3
                    [ class "text-3xl" ]
                    [ text "Left" ]
                ]

            -- right column
            , Html.div
                [ class "text-center w-full md:w-0 md:flex-grow px-6" ]
                [ h2
                    [ class "text-3xl" ]
                    [ text "Right" ]
                ]
            ]
        ]


viewLoggedIn : String -> Html msg
viewLoggedIn username =
    div
        [ class "" ]
        [ text <| "Hello, " ++ username ]


viewLoggedOut : Html msg
viewLoggedOut =
    div
        [ class "" ]
        [ text "You are not logged in." ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
