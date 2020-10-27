module View.Messages exposing (view)

import Content
import ContentChoices exposing (triggeredByChoicesGetMatches)
import Copy.Keys exposing (Key(..))
import Copy.Text exposing (t)
import Dict exposing (Dict)
import GameData exposing (CheckboxData, GameData, ScoreType(..), filterMessages)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra
import Markdown
import Message exposing (Msg(..))
import Route exposing (Route(..))
import Set exposing (Set)
import View.ChoiceButtons


view : GameData -> Content.Datastore -> Html Msg
view gamedata datastore =
    ul [ class "message-list p-0" ]
        (Dict.values
            (filterMessages datastore.messages gamedata.choices)
            |> List.map (renderMessageAndPrompt gamedata.choices gamedata.checkboxSet gamedata.teamName datastore)
        )


renderMessageAndPrompt : List String -> CheckboxData -> String -> Content.Datastore -> Content.MessageData -> Html Msg
renderMessageAndPrompt choices checkboxes team datastore message =
    let
        actualTriggers =
            String.split "|" (Maybe.withDefault "" (List.head (triggeredByChoicesGetMatches choices message.triggered_by)))
    in
    li []
        [ div [ class "typing-indicator" ] [ span [] [ text "" ], span [] [ text "" ], span [] [ text "" ] ]
        , if isScoreTime actualTriggers then
            renderScore "AL" actualTriggers team datastore

          else
            text ""
        , renderMessage message.author message.content
        , renderPrompt message choices checkboxes team
        ]


renderScore : String -> List String -> String -> Content.Datastore -> Html Msg
renderScore from triggers team datastore =
    let
        triggerDepth =
            String.fromInt (List.length (filterChoiceString triggers))

        previousChoices =
            List.reverse (Maybe.withDefault [] (List.Extra.init triggers))

        latestChoice =
            Maybe.withDefault "" (List.Extra.last triggers)
    in
    div
        [ class ("message al w-75 float-left mt-3 ml-3 py-2 triggers-" ++ triggerDepth) ]
        [ div [ class "mx-3" ]
            [ p [ class "message-from m-0" ] [ text from ]
            , p [] [ text (t WellDone ++ team) ]
            , p [] [ text (t Results) ]
            , p [] [ text ("Success: " ++ String.fromInt (GameData.updateScore Success datastore previousChoices latestChoice) ++ "%") ]
            , p [] [ text ("Economic: £" ++ String.fromInt (GameData.updateScore Economic datastore previousChoices latestChoice) ++ ",000,000 remaining") ]
            , p [] [ text ("Harm: " ++ String.fromInt (GameData.updateScore Harm datastore previousChoices latestChoice)) ]
            ]
        ]


renderMessage : String -> String -> Html Msg
renderMessage from message =
    div
        [ class "message al w-75 float-left mt-3 ml-3 py-2" ]
        [ div [ class "mx-3" ]
            [ p [ class "message-from m-0" ]
                [ text from ]
            , Markdown.toHtml [ class "card-text" ] message
            ]
        ]


renderPrompt : Content.MessageData -> List String -> CheckboxData -> String -> Html Msg
renderPrompt message choices checkboxes team =
    if List.length message.choices > 0 then
        div
            [ class "message player w-75 float-right mt-3 mr-3 py-2" ]
            [ div [ class "mx-3" ]
                [ p [ class "message-from m-0" ]
                    [ text (t FromPlayerTeam ++ team) ]
                , let
                    playerMessage =
                        case message.playerMessage of
                            Nothing ->
                                text ""

                            Just playerMessageText ->
                                Markdown.toHtml [ class "playerMessageText" ] playerMessageText
                  in
                  playerMessage
                , -- Lovely hack for multi choice messages (only choose-1-2-3 for now)
                  if message.basename == "choose-1-2-3" then
                    View.ChoiceButtons.renderCheckboxes
                        (List.map View.ChoiceButtons.choiceStringsToButtons message.choices)
                        checkboxes

                  else
                    div []
                        (View.ChoiceButtons.renderButtons
                            (List.map View.ChoiceButtons.choiceStringsToButtons message.choices)
                            (ContentChoices.getChoiceChosen choices message)
                        )
                ]
            ]

    else
        text ""


{-| Determines if the a score should be displayed in the messages
based on the length of the player's choice string.
-}
isScoreTime : List String -> Bool
isScoreTime triggers =
    if List.length (filterChoiceString triggers) == 2 || List.length (filterChoiceString triggers) == 4 || List.length (filterChoiceString triggers) == 5 then
        True

    else
        False


{-| Helper function to filter a string of choices for any
words that don't contributes to a unique path.
-}
filterChoiceString : List String -> List String
filterChoiceString input =
    let
        genericWords =
            [ "init", "start", "step", "change" ]
    in
    List.filter (\item -> not (List.member item genericWords)) input
