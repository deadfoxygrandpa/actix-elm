module Page.Home exposing (Model(..), Msg(..), init, subscriptions, update, view)

import Browser
import Cmd.Extra exposing (withCmd, withNoCmd)
import Html exposing (..)
import Html.Attributes exposing (class)
import Session exposing (..)
import Style


type Model
    = TBC


type Msg
    = TBD


init : ( Model, Cmd Msg )
init =
    ( TBC, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( _, _ ) ->
            model |> withNoCmd


view : Model -> Session -> { title : String, content : Html Msg }
view model session =
    { title = "Home"
    , content =
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
    }


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
