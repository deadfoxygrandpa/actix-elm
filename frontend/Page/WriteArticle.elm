module Page.WriteArticle exposing (Model, Msg(..), UUID, init, subscriptions, update, view)

import Article
import Cmd.Extra exposing (withCmd, withNoCmd)
import File
import File.Select
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events
import Json.Decode
import Page.Article
import Session
import Style
import Task
import Time


type alias Model =
    { session : Session.Session
    , uuid : UUID
    , article : Maybe Article.Article
    , headline : String
    , summary : String
    , body : String
    , image : Maybe String
    , dropZone : DropModel
    }


type alias UUID =
    String


type Msg
    = SubmittedForm
    | EnteredHeadline String
    | EnteredSummary String
    | EnteredBody String
    | ClickedImageButton
    | SelectedImage File.File
    | DecodedImage String
    | FileDrop DropMsg
    | NoOp


init : Session.Session -> UUID -> ( Model, Cmd Msg )
init session uuid =
    Model session uuid Nothing "" "" "" Nothing dropInit |> withNoCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmittedForm ->
            let
                articleSummary =
                    Article.Article
                        0
                        model.headline
                        (Time.millisToPosix 0)
                        model.body
                        model.summary
                        (Session.getUsernameUnsafe model.session)
                        model.image
            in
            { model | article = Just articleSummary } |> withNoCmd

        EnteredHeadline s ->
            { model | headline = s } |> withNoCmd

        EnteredSummary s ->
            { model | summary = s } |> withNoCmd

        EnteredBody s ->
            { model | body = s } |> withNoCmd

        ClickedImageButton ->
            model |> withCmd selectImage

        SelectedImage file ->
            model |> withCmd (Task.perform DecodedImage <| File.toUrl file)

        DecodedImage url ->
            { model | image = Just url } |> withNoCmd

        FileDrop (Drop (file :: fs)) ->
            model |> withCmd (Task.perform DecodedImage <| File.toUrl file)

        FileDrop subMsg ->
            { model | dropZone = dropUpdate subMsg model.dropZone } |> withNoCmd

        NoOp ->
            model |> withNoCmd


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Write Article"
    , content =
        div
            [ class "w-full m-4 grid grid-cols-4 grid-rows-3 gap-4 mt-4" ]
            [ div
                [ class "col-start-1 col-span-2 row-start-1" ]
                [ form
                    [ Html.Events.onSubmit SubmittedForm ]
                    [ Style.formInputField "headline" Nothing [ Html.Events.onInput EnteredHeadline ]
                    , Style.formInputField "summary" Nothing [ Html.Events.onInput EnteredSummary ]
                    , Style.formTextField "body" Nothing [ Html.Events.onInput EnteredBody, class "h-64" ]
                    , Style.formButtonNoSubmit "Add image" [ Html.Events.onClick ClickedImageButton ]
                    , Style.formButton "Save" []
                    , Html.map FileDrop <| viewFileDropArea model.dropZone
                    ]
                , case model.article of
                    Just article ->
                        Article.articleSummaryCard (\_ -> NoOp) (Article.summarize article)

                    Nothing ->
                        text "nothing"
                ]
            , div
                [ class "col-start-3 col-span-2 row-start-1" ]
                [ case model.article of
                    Just article ->
                        div [ class "m-4" ] [ Page.Article.viewArticle article ]

                    Nothing ->
                        text "Nothing"
                ]
            ]
    }


selectImage : Cmd Msg
selectImage =
    File.Select.file [ "image/png" ] SelectedImage


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- File drop area


type DropMsg
    = DragEnter
    | DragLeave
    | DragOver
    | Drop (List File.File)


type DropModel
    = Hover
    | NoHover


dropInit : DropModel
dropInit =
    NoHover


dropUpdate : DropMsg -> DropModel -> DropModel
dropUpdate msg model =
    case msg of
        DragEnter ->
            Hover

        DragLeave ->
            NoHover

        DragOver ->
            Hover

        Drop _ ->
            NoHover


dropHandlers : List (Html.Attribute DropMsg)
dropHandlers =
    [ onDragEnter
    , onDragLeave
    , onDragOver
    , onDragDrop
    ]


onDragEnter : Html.Attribute DropMsg
onDragEnter =
    Html.Events.custom "dragenter" (Json.Decode.succeed { message = DragEnter, preventDefault = True, stopPropagation = False })


onDragLeave : Html.Attribute DropMsg
onDragLeave =
    Html.Events.custom "dragleave" (Json.Decode.succeed { message = DragLeave, preventDefault = True, stopPropagation = False })


onDragOver : Html.Attribute DropMsg
onDragOver =
    Html.Events.custom "dragover" (Json.Decode.succeed { message = DragOver, preventDefault = True, stopPropagation = False })


onDragDrop : Html.Attribute DropMsg
onDragDrop =
    Html.Events.custom "drop" <|
        Json.Decode.map (\msg -> { message = Drop msg, preventDefault = True, stopPropagation = True }) files


files : Json.Decode.Decoder (List File.File)
files =
    Json.Decode.field "dataTransfer" (Json.Decode.field "files" (Json.Decode.list File.decoder))


viewFileDropArea : DropModel -> Html DropMsg
viewFileDropArea model =
    let
        hover =
            case model of
                Hover ->
                    class "bg-red-100"

                NoHover ->
                    class "bg-gray-100"
    in
    Html.div
        (dropHandlers ++ [ hover ])
        [ text "files" ]
