module Article exposing (Article, ArticleSummary, articleDecoder, articleSummaryCard, articleSummaryDecoder, time)

import Html exposing (..)
import Html.Attributes exposing (class)
import Json.Decode exposing (Decoder, field, int, nullable, string)
import Time


time : Decoder Time.Posix
time =
    Json.Decode.map
        (\n -> Time.millisToPosix <| n * 1000)
        (field "secs_since_epoch" int)


type alias Article =
    { articleID : Int
    , headlineCN : String
    , dateCreated : Time.Posix
    , articleBody : String
    , summary : String
    , author : String
    , image : Maybe String
    }


articleDecoder : Decoder Article
articleDecoder =
    Json.Decode.map7 Article
        (field "id" int)
        (field "headline_cn" string)
        (field "date_created" time)
        (field "article_body" string)
        (field "summary" string)
        (field "author" string)
        (field "image" (nullable string))


type alias ArticleSummary =
    { articleID : Int
    , headlineCN : String
    , dateCreated : Time.Posix
    , summary : String
    , author : String
    , image : Maybe String
    }


articleSummaryDecoder : Decoder ArticleSummary
articleSummaryDecoder =
    Json.Decode.map6 ArticleSummary
        (field "id" int)
        (field "headline_cn" string)
        (field "date_created" time)
        (field "summary" string)
        (field "author" string)
        (field "image" (nullable string))


articleSummaryCard : ArticleSummary -> Html msg
articleSummaryCard articleSummary =
    div
        [ class "w-full md:h-48 h-md block md:flex md:flex-row" ]
        [ div
            [ class "float-none h-48 md:h-auto bg-cover bg-center overflow-hidden md:w-48 flex-shrink-0"
            , Html.Attributes.style "background-image" "url('/image/placeholder.jpg')"
            ]
            []
        , div
            [ class "md:flex md:flex-col md:justify-between md:flex-grow md:px-4 overflow-auto" ]
            [ h3 [ class "font-bold text-3xl" ] [ text articleSummary.headlineCN ]
            , h1 [ class "font-light text-lg" ] [ text articleSummary.summary ]
            , div
                []
                [ span [ class "text-sm mr-4" ] [ text articleSummary.author ]
                , span [ class "text-sm" ] [ articleSummary.dateCreated |> timeToDate |> text ]
                ]
            ]
        ]


timeToDate : Time.Posix -> String
timeToDate posix =
    let
        zone =
            Time.utc
    in
    String.concat
        [ posix |> Time.toYear zone |> String.fromInt
        , "年"
        , posix |> toMonth zone
        , posix |> Time.toDay zone |> String.fromInt
        , "日"
        ]


toMonth : Time.Zone -> Time.Posix -> String
toMonth zone posix =
    let
        month =
            Time.toMonth zone posix
    in
    case month of
        Time.Jan ->
            "1月"

        Time.Feb ->
            "2月"

        Time.Mar ->
            "3月"

        Time.Apr ->
            "4月"

        Time.May ->
            "5月"

        Time.Jun ->
            "6月"

        Time.Jul ->
            "7月"

        Time.Aug ->
            "8月"

        Time.Sep ->
            "9月"

        Time.Oct ->
            "10月"

        Time.Nov ->
            "11月"

        Time.Dec ->
            "12月"
