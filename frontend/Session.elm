module Session exposing (Msg(..), Session(..), changeLanguage, getKey, getLanguage, getUsername, getUsernameUnsafe, init, loggedIn)

import Browser.Navigation exposing (Key)
import Localization exposing (Language)
import Maybe



-- session stores the nav key, current interface language, and username


type Session
    = Session Key Language (Maybe String)


type Msg
    = ChangeLanguage


init : Key -> Language -> Maybe String -> Session
init =
    Session


getKey : Session -> Key
getKey (Session key _ _) =
    key


getLanguage : Session -> Language
getLanguage (Session _ lang _) =
    lang


changeLanguage : Session -> Session
changeLanguage (Session key lang username) =
    let
        newLang =
            case lang of
                Localization.English ->
                    Localization.Chinese

                Localization.Chinese ->
                    Localization.English
    in
    init key newLang username


getUsername : Session -> Maybe String
getUsername (Session _ _ username) =
    username


getUsernameUnsafe : Session -> String
getUsernameUnsafe session =
    getUsername session |> Maybe.withDefault ""


loggedIn : Session -> Bool
loggedIn session =
    case getUsername session of
        Just _ ->
            True

        Nothing ->
            False
