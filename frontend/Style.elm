module Style exposing (formButton, formInputField, link)

import Html exposing (..)
import Html.Attributes exposing (..)
import String



-- General classes should be split into lines like:
-- class [shape, color, etc]
-- class [typography]
-- class [focus]
-- class [hover]


formInputField : String -> List (Attribute msg) -> Html msg
formInputField label attributes =
    let
        classes =
            [ class "shadow-md appearance-none border rounded w-full py-2 px-3"
            , class "focus:shadow-outline focus:outline-none"
            ]

        attrs =
            classes ++ attributes
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
