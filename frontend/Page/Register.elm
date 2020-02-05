module Page.Register exposing (Form, FormMsg(..), Model, Msg(..), init, subscriptions, update, view, viewForm)

import Api
import Browser
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (Html, text)
import Html.Attributes exposing (class)
import Html.Events
import Http
import Json.Encode
import List
import Route
import Session
import String
import Style


type alias Model =
    { form : Form
    , session : Session.Session
    }


type alias Form =
    { username : String
    , password : String
    , confirm : String
    , reply : Maybe String
    , usernameExists : Bool
    , validationErrors : List ValidationError
    }


encode : Form -> Json.Encode.Value
encode form =
    let
        username =
            form.username |> String.toLower |> String.trim
    in
    Json.Encode.object
        [ ( "username", Json.Encode.string username )
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


init : Session.Session -> ( Model, Cmd Msg )
init session =
    { form = initForm
    , session = session
    }
        |> (if Session.loggedIn session then
                withCmd (Session.getKey session |> Route.replaceToHome)

            else
                withNoCmd
           )


initForm : Form
initForm =
    { username = "", password = "", confirm = "", reply = Nothing, usernameExists = False, validationErrors = [] }


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
            case validateForm form of
                [] ->
                    form |> withCmd (login form)

                errors ->
                    { form | validationErrors = errors } |> withNoCmd

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
    , content = Html.div [ class "fade-in" ] [ viewForm model.form |> Html.map GotFormMsg ]
    }


viewForm : Form -> Html FormMsg
viewForm form =
    let
        ( invalidUsername, invalidUsernameText ) =
            showError InvalidUsername form.validationErrors

        ( passwordTooShort, passwordTooShortText ) =
            showError PasswordTooShort form.validationErrors

        ( passwordsDontMatch, passwordsDontMatchText ) =
            showError PasswordsDontMatch form.validationErrors
    in
    Html.div
        [ class "w-full max-w-xs container" ]
        [ Html.form
            [ Html.Events.onSubmit SubmittedForm ]
            [ Html.div
                [ class "bg-white shadow-md rounded px-8 pt-6 pb-8 m-4" ]
                [ Style.formInputField "Email address"
                    invalidUsernameText
                    [ Html.Events.onInput EnteredUsername
                    , Html.Attributes.value form.username
                    , highlightError (form.usernameExists || invalidUsername)
                    ]
                , Style.formInputField "Password"
                    passwordTooShortText
                    [ Html.Events.onInput EnteredPassword
                    , Html.Attributes.value form.password
                    , Html.Attributes.type_ "password"
                    , highlightError passwordTooShort
                    ]
                , Style.formInputField "Repeat Password"
                    passwordsDontMatchText
                    [ Html.Events.onInput EnteredConfirm
                    , Html.Attributes.value form.confirm
                    , Html.Attributes.type_ "password"
                    , highlightError passwordsDontMatch
                    ]
                , Style.formButton "Register" []
                , case form.reply of
                    Just s ->
                        Html.div [ class "text-sm text-red-500 italic" ] [ text s ]

                    Nothing ->
                        Html.div [] []
                ]
            , Style.linkAlert "Have an account?" "Sign in." Route.Login
            ]
        ]


highlightError : Bool -> Html.Attribute msg
highlightError bool =
    if not bool then
        class ""

    else
        class "border-red-500"


showError : ValidationError -> List ValidationError -> ( Bool, Maybe String )
showError error errors =
    if List.member error errors then
        ( True, Just (toStr error) )

    else
        ( False, Nothing )


type ValidationError
    = InvalidUsername
    | PasswordTooShort
    | PasswordsDontMatch


toStr : ValidationError -> String
toStr e =
    case e of
        InvalidUsername ->
            "Username is not a valid email address"

        PasswordTooShort ->
            "Password must be 8 or more characters"

        PasswordsDontMatch ->
            "Passwords don't match"


validateForm : Form -> List ValidationError
validateForm form =
    justs
        [ validateUsername form.username
        , validatePassword form.password
        , validateConfirm form.password form.confirm
        ]


validateUsername : String -> Maybe ValidationError
validateUsername username =
    if String.contains "@" username && String.length username > 3 then
        Nothing

    else
        Just InvalidUsername


validatePassword : String -> Maybe ValidationError
validatePassword password =
    if String.length password < 8 then
        Just PasswordTooShort

    else
        Nothing


validateConfirm : String -> String -> Maybe ValidationError
validateConfirm password confirm =
    if password /= confirm then
        Just PasswordsDontMatch

    else
        Nothing


justs : List (Maybe a) -> List a
justs maybes =
    List.filterMap identity maybes
