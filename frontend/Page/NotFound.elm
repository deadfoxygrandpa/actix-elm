module Page.NotFound exposing (view)

import Html exposing (Html, div, h1, img, main_, text)
import Html.Attributes exposing (alt, class, id, src, tabindex)
import Route
import Style



-- VIEW


view : { title : String, content : Html msg }
view =
    { title = "Page Not Found"
    , content =
        main_ [ id "content", class "container", tabindex -1 ]
            [ text "Page not found." |> Style.bodyAlert
            ]
    }
