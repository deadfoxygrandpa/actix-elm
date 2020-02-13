module Page.WriteArticle exposing (Model, Msg(..), UUID, init, subscriptions, update, view)

import Article
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events
import Session
import Style
import Time


type alias Model =
    { session : Session.Session
    , uuid : UUID
    , article : Maybe Article.ArticleSummary
    , headline : String
    , summary : String
    , body : String
    }


type alias UUID =
    String


type Msg
    = SubmittedForm
    | EnteredHeadline String
    | EnteredSummary String
    | EnteredBody String
    | NoOp


init : Session.Session -> UUID -> ( Model, Cmd Msg )
init session uuid =
    Model session uuid Nothing "" "" "" |> withNoCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmittedForm ->
            let
                articleSummary =
                    Article.ArticleSummary
                        0
                        model.headline
                        (Time.millisToPosix 0)
                        model.summary
                        (Session.getUsernameUnsafe model.session)
                        Nothing
            in
            { model | article = Just articleSummary } |> withNoCmd

        EnteredHeadline s ->
            { model | headline = s } |> withNoCmd

        EnteredSummary s ->
            { model | summary = s } |> withNoCmd

        EnteredBody s ->
            { model | body = s } |> withNoCmd

        NoOp ->
            model |> withNoCmd


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Write Article"
    , content =
        div
            [ class "w-full grid grid-cols-4 gap-4 mt-4" ]
            [ div
                [ class "col-start-2 col-span-2 row-start-1" ]
                [ form
                    [ Html.Events.onSubmit SubmittedForm ]
                    [ Style.formInputField "headline" Nothing [ Html.Events.onInput EnteredHeadline ]
                    , Style.formInputField "summary" Nothing [ Html.Events.onInput EnteredSummary ]
                    , Style.formTextField "body" Nothing [ Html.Events.onInput EnteredBody, class "h-64" ]
                    , Style.formButton "Save" []
                    ]
                ]
            , div
                [ class "col-start-1 col-span-1 row-start-1" ]
                [ case model.article of
                    Just article ->
                        Article.articleSummaryCard (\_ -> NoOp) article

                    Nothing ->
                        text "nothing"
                ]
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
