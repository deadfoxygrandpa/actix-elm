module Session exposing
    ( Credentials
    , MenuStatus(..)
    , Msg(..)
    , Role(..)
    , Session(..)
    , changeLanguage
    , changeMenu
    , getKey
    , getLanguage
    , getMenuStatus
    , getRoles
    , getUsername
    , getUsernameUnsafe
    , init
    , isAdmin
    , loggedIn
    , logout
    )

import Browser.Navigation exposing (Key)
import Json.Decode exposing (Decoder, field, int, list, string)
import Localization exposing (Language)
import Maybe



-- session stores the nav key, current interface language, username + roles, if the menu is open


type Session
    = Session Key Language (Maybe Credentials) MenuStatus


type alias Credentials =
    { username : String
    , roles : List Role
    }


type Role
    = Admin
    | Author
    | Reviewer
    | Publisher
    | None


type MenuStatus
    = Opened
    | Closed
    | Init


type Msg
    = ChangeLanguage
    | ChangeMenu


init : Key -> Language -> Maybe String -> Session
init key lang credentials =
    Session key lang (makeCredentials credentials) Init


makeCredentials : Maybe String -> Maybe Credentials
makeCredentials credentials =
    credentials
        |> Maybe.andThen
            (Json.Decode.decodeString credentialsDecoder
                >> Result.toMaybe
            )


credentialsDecoder : Decoder Credentials
credentialsDecoder =
    Json.Decode.map2 Credentials
        (field "username" string)
        (field "roles" (list role))


role : Decoder Role
role =
    let
        intToRole n =
            case n of
                1 ->
                    Admin

                2 ->
                    Author

                3 ->
                    Reviewer

                4 ->
                    Publisher

                _ ->
                    None
    in
    Json.Decode.map intToRole int


getKey : Session -> Key
getKey (Session key _ _ _) =
    key


getLanguage : Session -> Language
getLanguage (Session _ lang _ _) =
    lang


changeLanguage : Session -> Session
changeLanguage (Session key lang credentials open) =
    let
        newLang =
            case lang of
                Localization.English ->
                    Localization.Chinese

                Localization.Chinese ->
                    Localization.English
    in
    Session key newLang credentials open


getUsername : Session -> Maybe String
getUsername (Session _ _ credentials _) =
    Maybe.map .username credentials


getUsernameUnsafe : Session -> String
getUsernameUnsafe session =
    getUsername session |> Maybe.withDefault ""


getRoles : Session -> List Role
getRoles (Session _ _ credentials _) =
    Maybe.map .roles credentials |> Maybe.withDefault []


isAdmin : Session -> Bool
isAdmin =
    List.member Admin << getRoles


logout : Session -> Session
logout (Session key lang _ open) =
    Session key lang (makeCredentials Nothing) open


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
changeMenu (Session key lang credentials open) =
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
    Session key lang credentials menuStatus
