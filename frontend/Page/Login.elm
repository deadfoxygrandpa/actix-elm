module Page.Login exposing (Form, FormMsg(..), Model, Msg(..), init, update, view, viewForm)

import Api
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (Html, text)
import Html.Attributes
import Html.Events
import Http
import Json.Encode


type alias Model =
    { form : Form }


type alias Form =
    { username : String
    , password : String
    , reply : Maybe String
    }


encode : Form -> Json.Encode.Value
encode form =
    Json.Encode.object
        [ ( "username", Json.Encode.string form.username )
        , ( "password", Json.Encode.string form.password )
        ]


type Msg
    = GotFormMsg FormMsg


type FormMsg
    = SubmittedForm
    | EnteredUsername String
    | EnteredPassword String
    | SentLogin (Result Http.Error String)


init : Model
init =
    { form = initForm }


initForm : Form
initForm =
    { username = "", password = "", reply = Nothing }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFormMsg m ->
            let
                ( form_, formMsg_ ) =
                    updateForm m model.form
            in
            { model | form = form_ } |> withCmd (Cmd.map GotFormMsg formMsg_)


updateForm : FormMsg -> Form -> ( Form, Cmd FormMsg )
updateForm msg form =
    case msg of
        SubmittedForm ->
            form |> withCmd (login form)

        EnteredUsername s ->
            { form | username = s } |> withNoCmd

        EnteredPassword s ->
            { form | password = s } |> withNoCmd

        SentLogin rs ->
            case rs of
                Ok s ->
                    { form | reply = Just s } |> withNoCmd

                Err _ ->
                    form |> withNoCmd


login : Form -> Cmd FormMsg
login form =
    Api.post
        { endpoint = Api.login
        , body = Http.jsonBody <| encode form
        , expect = Http.expectJson SentLogin Api.msgDecoder
        }


view : Model -> Html Msg
view model =
    Html.div [] [ viewForm model.form |> Html.map GotFormMsg ]


viewForm : Form -> Html FormMsg
viewForm form =
    Html.form
        [ Html.Events.onSubmit SubmittedForm ]
        [ Html.div
            []
            [ Html.div
                []
                [ Html.label
                    []
                    [ text "Email address" ]
                ]
            , Html.div
                []
                [ Html.input
                    [ Html.Events.onInput EnteredUsername
                    , Html.Attributes.value form.username
                    ]
                    []
                ]
            ]
        , Html.div
            []
            [ Html.div
                []
                [ Html.label
                    []
                    [ text "Password" ]
                ]
            , Html.div
                []
                [ Html.input
                    [ Html.Events.onInput EnteredPassword
                    , Html.Attributes.value form.password
                    , Html.Attributes.type_ "password"
                    ]
                    []
                ]
            ]
        , Html.div
            []
            [ Html.div
                []
                []
            , Html.div
                []
                [ Html.button
                    []
                    [ text "Login" ]
                ]
            ]
        , case form.reply of
            Just s ->
                Html.div [] [ text s ]

            Nothing ->
                Html.div [] []
        ]
