module Session exposing (MenuStatus(..), Msg(..), Session(..), changeLanguage, changeMenu, getKey, getLanguage, getMenuStatus, getUsername, getUsernameUnsafe, init, loggedIn, logout)

import Browser.Navigation exposing (Key)
import Localization exposing (Language)
import Maybe



-- session stores the nav key, current interface language, username, if the menu is open


type Session
    = Session Key Language (Maybe String) MenuStatus


type MenuStatus
    = Opened
    | Closed
    | Init


type Msg
    = ChangeLanguage
    | ChangeMenu


init : Key -> Language -> Maybe String -> Session
init key lang username =
    Session key lang username Init


getKey : Session -> Key
getKey (Session key _ _ _) =
    key


getLanguage : Session -> Language
getLanguage (Session _ lang _ _) =
    lang


changeLanguage : Session -> Session
changeLanguage (Session key lang username open) =
    let
        newLang =
            case lang of
                Localization.English ->
                    Localization.Chinese

                Localization.Chinese ->
                    Localization.English
    in
    Session key newLang username open


getUsername : Session -> Maybe String
getUsername (Session _ _ username _) =
    username


getUsernameUnsafe : Session -> String
getUsernameUnsafe session =
    getUsername session |> Maybe.withDefault ""


logout : Session -> Session
logout (Session key lang _ open) =
    Session key lang Nothing open


loggedIn : Session -> Bool
loggedIn session =
    case getUsername session of
        Just _ ->
            True

        Nothing ->
            False


getMenuStatus : Session -> MenuStatus
getMenuStatus (Session _ _ _ open) =
    open


changeMenu : Session -> Session
changeMenu (Session key lang username open) =
    let
        menuStatus =
            case open of
                Init ->
                    Opened

                Opened ->
                    Closed

                Closed ->
                    Opened
    in
    Session key lang username menuStatus
