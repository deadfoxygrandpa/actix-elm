module Page.Register exposing (Form, FormMsg(..), Model, Msg(..), init, subscriptions, update, view, viewForm)

import Api
import Browser
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Html.Events
import Http
import Json.Encode
import Style


type alias Model =
    { form : Form }


type alias Form =
    { username : String
    , password : String
    , confirm : String
    , reply : Maybe String
    , usernameExists : Bool
    }


encode : Form -> Json.Encode.Value
encode form =
    Json.Encode.object
        [ ( "username", Json.Encode.string form.username )
        , ( "password", Json.Encode.string form.password )
        , ( "confirm", Json.Encode.string form.confirm )
        ]


type Msg
    = GotFormMsg FormMsg


type FormMsg
    = SubmittedForm
    | EnteredUsername String
    | EnteredPassword String
    | EnteredConfirm String
    | SentRegister (Result Http.Error String)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    { form = initForm } |> withNoCmd


initForm : Form
initForm =
    { username = "", password = "", confirm = "", reply = Nothing, usernameExists = False }


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

        EnteredConfirm s ->
            { form | confirm = s } |> withNoCmd

        SentRegister rs ->
            case rs of
                Ok "AuthenticationError(\"Username already exists\")" ->
                    { form | reply = Just "User already exists", usernameExists = True } |> withNoCmd

                Ok s ->
                    { form | reply = Just s, usernameExists = False } |> withNoCmd

                Err _ ->
                    form |> withNoCmd


login : Form -> Cmd FormMsg
login form =
    Api.post
        { endpoint = Api.register
        , body = Http.jsonBody <| encode form
        , expect = Http.expectJson SentRegister Api.msgDecoder
        }


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Register"
    , content = Html.div [] [ viewForm model.form |> Html.map GotFormMsg ]
    }


viewForm : Form -> Html FormMsg
viewForm form =
    Html.div
        [ class "w-full max-w-xs container" ]
        [ Html.form
            [ Html.Events.onSubmit SubmittedForm ]
            [ Html.div
                [ class "bg-white shadow-md rounded px-8 pt-6 pb-8 m-4" ]
                [ Style.formInputField "Email address"
                    [ Html.Events.onInput EnteredUsername
                    , Html.Attributes.value form.username
                    , class
                        (if form.usernameExists then
                            "border-red-500"

                         else
                            ""
                        )
                    ]
                , Style.formInputField "Password"
                    [ Html.Events.onInput EnteredPassword
                    , Html.Attributes.value form.password
                    , Html.Attributes.type_ "password"
                    ]
                , Style.formInputField "Repeat Password"
                    [ Html.Events.onInput EnteredConfirm
                    , Html.Attributes.value form.confirm
                    , Html.Attributes.type_ "password"
                    ]
                , Style.formButton "Register" []
                , case form.reply of
                    Just s ->
                        Html.div [ class "text-sm text-red-500 italic" ] [ text s ]

                    Nothing ->
                        Html.div [] []
                ]
            ]
        ]
