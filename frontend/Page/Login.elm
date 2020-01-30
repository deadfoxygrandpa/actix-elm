module Page.Login exposing (FormMsg(..), Model, Msg(..), init, subscriptions, update, view, viewForm)

import Api
import Browser
import Browser.Navigation
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (Html, text)
import Html.Attributes
import Html.Events
import Http
import Json.Encode
import Route


type alias Model =
    { form : Api.LoginInfo }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = GotFormMsg FormMsg


type FormMsg
    = SubmittedForm
    | EnteredUsername String
    | EnteredPassword String
    | SentLogin (Result Http.Error String)


init : ( Model, Cmd Msg )
init =
    { form = initForm } |> withNoCmd


initForm : Api.LoginInfo
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


updateForm : FormMsg -> Api.LoginInfo -> ( Api.LoginInfo, Cmd FormMsg )
updateForm msg form =
    case msg of
        SubmittedForm ->
            form |> withCmd (Api.attemptLogin form SentLogin)

        EnteredUsername s ->
            { form | username = s } |> withNoCmd

        EnteredPassword s ->
            { form | password = s } |> withNoCmd

        SentLogin rs ->
            case rs of
                Ok "Success" ->
                    form |> withCmd (Route.load Route.Home)

                Ok s ->
                    { form | reply = Just s } |> withNoCmd

                Err _ ->
                    form |> withNoCmd


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Login"
    , content = Html.div [] [ viewForm model.form |> Html.map GotFormMsg ]
    }


viewForm : Api.LoginInfo -> Html FormMsg
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
