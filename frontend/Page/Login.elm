module Page.Login exposing (FormMsg(..), Model, Msg(..), init, subscriptions, update, view, viewForm)

import Api
import Browser
import Browser.Navigation
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (..)
import Html.Attributes exposing (class, for, href, id, placeholder, type_)
import Html.Events
import Http
import Json.Encode
import Localization
import Route
import Session
import Style


type alias Model =
    { form : Api.LoginInfo
    , session : Session.Session
    }


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
    | LoggedIn


init : Session.Session -> ( Model, Cmd Msg )
init session =
    { form = Api.initLoginInfo
    , session = session
    }
        |> (if Session.loggedIn session then
                withCmd (Route.replaceUrl (Session.getKey session) Route.Home)

            else
                withNoCmd
           )


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
                    { form | wrongPassword = False, pageMessage = Just "Success." } |> withCmd (Api.delay 3000 LoggedIn)

                Ok "AuthenticationError(\"Wrong password\")" ->
                    { form | reply = Just "Wrong password.", wrongPassword = True } |> withNoCmd

                Ok "AuthenticationError(\"Username does not exist\")" ->
                    { form | reply = Just "User does not exist.", wrongPassword = False } |> withNoCmd

                Ok "AuthenticationError(\"User is not activated\")" ->
                    { form | reply = Just "Email address is not confirmed. Please check your email to verify this account.", wrongPassword = False } |> withNoCmd

                Ok s ->
                    { form | reply = Just s, wrongPassword = False } |> withNoCmd

                Err _ ->
                    form |> withNoCmd

        LoggedIn ->
            form |> withCmd (Route.load Route.Home)


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Login"
    , content = viewForm model.form |> Html.map GotFormMsg
    }


viewForm : Api.LoginInfo -> Html FormMsg
viewForm form =
    Html.div
        [ class "w-full max-w-xs container" ]
        [ Html.form
            [ Html.Events.onSubmit SubmittedForm
            , class "bg-white shadow-md rounded px-8 pt-6 pb-8 m-4"
            ]
            [ Style.formInputField "Email address"
                Nothing
                [ Html.Events.onInput EnteredUsername
                , Html.Attributes.value form.username
                ]
            , Style.formInputField "Password"
                Nothing
                [ Html.Events.onInput EnteredPassword
                , Html.Attributes.value form.password
                , Html.Attributes.type_ "password"
                , class
                    (if form.wrongPassword then
                        "border-red-500"

                     else
                        ""
                    )
                ]
            , Style.formButton "Sign in" []
            , case form.reply of
                Just s ->
                    Html.div [ class "text-sm text-red-500 italic" ] [ text s ]

                Nothing ->
                    Html.div [] []
            , case form.pageMessage of
                Just s ->
                    Html.div [ class "text-sm italic" ] [ text s ]

                Nothing ->
                    Html.div [] []
            ]
        , Style.linkAlert "Are you new?" "Create an account." Route.Register
        ]
