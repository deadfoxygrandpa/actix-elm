module Style exposing
    ( backgroundImage
    , bodyAlert
    , divider
    , formButton
    , formInputField
    , link
    , linkAlert
    , loadingIcon
    , maybeBackgroundImage
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Ionicon
import Localization
import Route
import String



-- General classes should be split into lines like:
-- class [shape, color, etc]
-- class [typography]
-- class [focus]
-- class [hover]


formInputField : String -> Maybe String -> List (Attribute msg) -> Html msg
formInputField label error attributes =
    let
        classes =
            [ class "shadow-md appearance-none border rounded w-full py-2 px-3"
            , class "focus:shadow-outline focus:outline-none"
            ]

        attrs =
            classes ++ attributes

        errorText =
            case error of
                Nothing ->
                    " "

                Just s ->
                    s
    in
    Html.div
        [ class "mb-4" ]
        [ Html.label
            [ class "block mb-2"
            , class "text-gray-700 text-sm font-bold font-sans"
            ]
            [ text label ]
        , Html.input
            attrs
            []
        , Html.span
            [ class "text-xs text-red-500 italic" ]
            [ text errorText ]
        ]


formButton : String -> List (Attribute msg) -> Html msg
formButton label attributes =
    let
        attrs =
            class "" :: attributes
    in
    Html.div
        attrs
        [ Html.button
            [ class "border rounded shadow-md px-3 py-2 bg-green-500 font-bold text-sm text-white mb-2"
            , class "focus:bg-green-600"
            , class "hover:bg-green-600"
            ]
            [ text label ]
        ]


link : Attribute msg
link =
    let
        classes =
            [ "mx-1"
            , "text-blue-500 underline"
            , "focus:text-blue-700"
            , "hover:text-blue-700"
            ]
    in
    class <| String.join " " classes


linkAlert : String -> String -> Route.Route -> Html msg
linkAlert label linkText route =
    Html.div
        [ class "w-full max-w-xs" ]
        [ Html.div
            [ class "text-center text-sm m-4 bg-white p-2 shadow-md rounded" ]
            [ span [] [ text label ]
            , a
                [ link
                , Route.href route
                ]
                [ text linkText ]
            ]
        ]


bodyAlert : Html msg -> Html msg
bodyAlert content =
    Html.div
        [ class "container max-w-sm text-center bg-white shadow-md rounded my-4 p-6" ]
        [ content ]


loadingIcon : Html msg
loadingIcon =
    Html.div [ class "loading flex-shrink" ] []


backgroundImage : String -> Attribute msg
backgroundImage filename =
    Html.Attributes.style "background-image" ("url('" ++ filename ++ "')")


maybeBackgroundImage : Maybe String -> Attribute msg
maybeBackgroundImage filename =
    Maybe.withDefault "/image/placeholder.jpg" filename |> backgroundImage


divider : Html msg
divider =
    Html.div [ class "w-full h-px divider my-4" ] []
