module Main exposing (main)

import Browser
import Browser.Dom
import Browser.Navigation
import Content
import Copy.Keys exposing (Key(..))
import Copy.Text exposing (t)
import Debug
import Dict
import GameData exposing (GameData, ScoreType(..), init)
import Html exposing (Html, div)
import Json.Decode
import Message exposing (Msg(..))
import Route exposing (Route(..), toString)
import Set
import Task
import Url
import View.Desktop
import View.Documents
import View.Emails
import View.Intro exposing (view)
import View.Messages exposing (view)
import View.Social



-- MODEL


type alias Model =
    { key : Browser.Navigation.Key
    , page : Route
    , data : Content.Datastore
    , gameData : GameData
    , visited : Set.Set String
    }


init : Flags -> Url.Url -> Browser.Navigation.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        maybeRoute =
            Route.fromUrl url

        datastore =
            Content.datastoreDictDecoder flags
    in
    -- If not a valid route, default to Desktop
    ( { key = key
      , page = Maybe.withDefault Intro maybeRoute
      , data = datastore
      , gameData = GameData.init
      , visited = Set.empty
      }
    , Cmd.none
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Browser.Navigation.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Browser.Navigation.load href
                    )

        UrlChanged url ->
            let
                newRoute =
                    -- If not a valid Route, default to Intro
                    Maybe.withDefault Intro (Route.fromUrl url)
            in
            ( { model | page = newRoute, visited = Set.insert (Route.toString newRoute) model.visited }, resetViewportTop )

        ChoiceButtonClicked choice ->
            let
                --debug =
                --   Debug.log "NEWSCORE" (Debug.toString (GameData.updateEconomicScore model.data model.gameData choice))
                newGameData =
                    { choices = choice :: model.gameData.choices
                    , teamName = model.gameData.teamName
                    , scoreSuccess = GameData.updateSuccessScore model.data model.gameData choice
                    , scoreEconomic = GameData.updateScore Economic model.data model.gameData choice
                    , scoreHarm = GameData.updateScore Harm model.data model.gameData choice
                    }
            in
            ( { model | gameData = newGameData }, Cmd.none )

        TeamChosen teamName ->
            let
                newGameData =
                    { choices = [ "init" ]
                    , teamName = teamName
                    , scoreSuccess = model.gameData.scoreSuccess
                    , scoreEconomic = model.gameData.scoreEconomic
                    , scoreHarm = model.gameData.scoreHarm
                    }
            in
            ( { model | gameData = newGameData }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )



--VIEW


viewDocument : Model -> Browser.Document Msg
viewDocument model =
    { title = t SiteTitle, body = [ view model ] }


view : Model -> Html Msg
view model =
    case model.page of
        Desktop ->
            View.Desktop.view model.gameData model.page

        Documents ->
            div []
                [ View.Desktop.renderWrapperWithNav model.gameData
                    model.page
                    [ View.Documents.list model.data.documents
                    ]
                ]

        Document id ->
            div []
                [ View.Desktop.renderWrapperWithNav model.gameData
                    model.page
                    [ View.Documents.single (Dict.get id model.data.documents)
                    ]
                ]

        Emails ->
            div []
                [ View.Desktop.renderWrapperWithNav model.gameData
                    model.page
                    [ View.Emails.list model.gameData model.data.emails model.visited
                    ]
                ]

        Email id ->
            div []
                [ View.Desktop.renderWrapperWithNav model.gameData
                    model.page
                    [ View.Emails.single model.gameData (Dict.get id model.data.emails)
                    ]
                ]

        Messages ->
            div []
                [ View.Desktop.renderWrapperWithNav model.gameData
                    model.page
                    [ View.Messages.view model.gameData model.data.messages
                    ]
                ]

        Social ->
            div []
                [ View.Desktop.renderWrapperWithNav model.gameData
                    model.page
                    [ View.Social.view model.gameData model.data.social
                    ]
                ]

        Intro ->
            div []
                [ View.Intro.view
                ]


resetViewportTop : Cmd Msg
resetViewportTop =
    Task.perform (\_ -> NoOp) (Browser.Dom.setViewport 0 0)



-- SUBSCRIPTIONS & FLAGS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias Flags =
    Json.Decode.Value


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = viewDocument
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }
