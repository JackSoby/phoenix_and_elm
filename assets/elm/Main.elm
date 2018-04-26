module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, id, placeholder, value)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, field, int, string)
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http exposing (..)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias User =
    { id : Int, name : String, email : String, phone : String, state : String, city : String }


type alias Model =
    { users : List User
    , name : String
    , email : String
    , phone : String
    , state : String
    , city : String
    , valid : Maybe Int
    , update : Maybe Int
    }


init : ( Model, Cmd Msg )
init =
    ( Model [] "" "" "" "" "" Nothing Nothing, getString )


type Msg
    = LoadAll (Result Http.Error (List User))
    | HandleNameInput String
    | HandleEmailInput String
    | HandlePhoneInput String
    | HandleCityInput String
    | HandleStateInput String
    | NewUser (Result Http.Error (List User))
    | UserDeleted (Result Http.Error String)
    | HandleValidate
    | HandleUpdateValidate
    | HandleDelete User
    | HandleUpdate User
    | UserUpdated (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadAll (Ok stringText) ->
            ( { model | users = stringText }, Cmd.none )

        HandleDelete deletedUser ->
            ( Model model.users "" "" "" "" "" Nothing Nothing, deleteUserCommand deletedUser )

        HandleUpdate updatedUser ->
            ( Model model.users updatedUser.name updatedUser.email updatedUser.phone updatedUser.state updatedUser.city Nothing (Just 1), Cmd.none )

        LoadAll (Err error) ->
            let
                errorText =
                    Debug.log "error: " error
            in
            ( model, Cmd.none )

        NewUser (Ok userlist) ->
            ( { model | users = userlist }, Cmd.none )

        UserDeleted (Ok userlist) ->
            ( model, getString )

        UserUpdated (Ok userlist) ->
            ( model, getString )

        UserUpdated (Err error) ->
            let
                errorText =
                    Debug.log "error: " error
            in
            ( model, Cmd.none )

        UserDeleted (Err error) ->
            let
                errorText =
                    Debug.log "error: " error
            in
            ( model, Cmd.none )

        NewUser (Err error) ->
            let
                errorText =
                    Debug.log "error: " error
            in
            ( model, Cmd.none )

        HandleNameInput nameInput ->
            ( { model | name = nameInput }, Cmd.none )

        HandleEmailInput emailInput ->
            ( { model | email = emailInput }, Cmd.none )

        HandlePhoneInput phoneInput ->
            ( { model | phone = phoneInput }, Cmd.none )

        HandleCityInput cityInput ->
            ( { model | city = cityInput }, Cmd.none )

        HandleStateInput stateInput ->
            ( { model | state = stateInput }, Cmd.none )

        HandleUpdateValidate ->
            if model.name == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else if model.phone == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else if model.email == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else if model.city == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else if model.state == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else
                ( Model model.users "" "" "" "" "" Nothing Nothing, encodeUser { name = model.name, email = model.email, phone = model.phone, state = model.state, city = model.city } )

        HandleValidate ->
            if model.name == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else if model.phone == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else if model.email == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else if model.city == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else if model.state == "" then
                ( Model model.users model.name model.email model.phone model.state model.city (Just 1) Nothing, Cmd.none )
            else
                ( Model model.users "" "" "" "" "" Nothing Nothing, encodeUser { name = model.name, email = model.email, phone = model.phone, state = model.state, city = model.city } )


view : Model -> Html Msg
view model =
    let
        renderedUsers =
            model.users
                |> List.map renderUserBox

        errorMessage =
            case model.valid of
                Just todoId ->
                    div [ class "warning-text" ] [ text "Please fill out all form fields" ]

                Nothing ->
                    div [] []

        newButton =
            case model.update of
                Just todoId ->
                    button [ class "crud-button-new", onClick HandleUpdateValidate ] [ text "update" ]

                Nothing ->
                    button [ class "crud-button-new", onClick HandleValidate ] [ text "new" ]
    in
    div [ class "wrapper-class" ]
        [ div [ class "users-text" ] [ text "Users" ]
        , div [ class "user-form" ]
            [ input [ placeholder "Name", class "input-field", onInput HandleNameInput, value model.name ] []
            , input [ placeholder "Phone", class "input-field", onInput HandlePhoneInput, value model.phone ] []
            , input [ placeholder "Email", class "input-field", onInput HandleEmailInput, value model.email ] []
            , input [ placeholder "City", class "input-field", onInput HandleCityInput, value model.city ] []
            , input [ placeholder "State", class "input-field", onInput HandleStateInput, value model.state ] []
            , newButton
            ]
        , errorMessage
        , div [] renderedUsers
        ]


renderUserBox : User -> Html Msg
renderUserBox user =
    div [ class "users-box" ]
        [ div [] [ span [] [ text "Name: " ], text user.name ]
        , div [] [ span [] [ text "Phone: " ], text user.phone ]
        , div [] [ span [] [ text "Email: " ], text user.email ]
        , div [] [ span [] [ text "City: " ], text user.city ]
        , div [] [ span [] [ text "State: " ], text user.state ]
        , button [ onClick (HandleDelete user), class "crud-button" ] [ text "delete" ]
        , button [ onClick (HandleUpdate user), class "crud-button" ] [ text "update" ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


getString : Cmd Msg
getString =
    Http.send LoadAll (Http.get "api/v1/users" jsonDecoder)


jsonDecoder : Decode.Decoder (List User)
jsonDecoder =
    Decode.field "data" stringDecoder


stringDecoder : Decode.Decoder (List User)
stringDecoder =
    Decode.list decodeText


encodeUser : { name : String, email : String, phone : String, state : String, city : String } -> Cmd Msg
encodeUser user =
    let
        encodedUser =
            Encode.object
                [ ( "name", Encode.string user.name )
                , ( "email", Encode.string user.email )
                , ( "phone", Encode.string user.phone )
                , ( "state", Encode.string user.state )
                , ( "city", Encode.string user.city )
                ]
    in
    newUser encodedUser


deleteUserCommand : User -> Cmd Msg
deleteUserCommand user =
    deleteUserRequest user
        |> Http.send UserDeleted


deleteUserRequest : User -> Http.Request String
deleteUserRequest user =
    Http.request
        { method = "DELETE"
        , headers = []
        , url = "api/v1/users/" ++ toString user.id
        , body = Http.emptyBody
        , expect = Http.expectString
        , timeout = Nothing
        , withCredentials = False
        }


newUser : Encode.Value -> Cmd Msg
newUser userInput =
    let
        body =
            userInput
                |> Http.jsonBody
    in
    Http.send NewUser (Http.post "api/v1/users" body jsonDecoder)


newDecoder : Decode.Decoder User
newDecoder =
    Decode.field "users" decodeText


decodeText : Decode.Decoder User
decodeText =
    Decode.map6 User
        (field "id" int)
        (field "name" string)
        (field "email" string)
        (field "phone" string)
        (field "state" string)
        (field "city" string)
