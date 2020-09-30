module View.Messages exposing (triggeredByWithChoiceStrings, view)

import Array exposing (set)
import Content
import Copy.Keys exposing (Key(..))
import Copy.Text exposing (t)
import Debug
import Dict exposing (Dict)
import GameData exposing (GameData, filterMessages, triggeredByChoicesGetMatches)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra
import Markdown
import Message exposing (Msg(..))
import Route exposing (Route(..))
import Set


type alias ButtonInfo =
    { label : String
    , action : String
    }


choiceStringsToButtons : String -> ButtonInfo
choiceStringsToButtons buttonString =
    let
        ( parsedString, action ) =
            ( case List.head (String.indexes "|" buttonString) of
                Nothing ->
                    buttonString

                Just val ->
                    String.dropLeft (val + 1) buttonString
            , case List.head (String.indexes "|" buttonString) of
                Nothing ->
                    buttonString

                Just val ->
                    String.left val buttonString
            )
    in
    { label = parsedString, action = action }


view : GameData -> Dict String Content.MessageData -> Html Msg
view gamedata messagesDict =
    ul [ class "message-list p-0" ]
        (List.reverse
            (Dict.values (filterMessages messagesDict gamedata.choices))
            |> List.map (renderMessageAndPrompt gamedata.choices)
        )


renderMessageAndPrompt : List String -> Content.MessageData -> Html Msg
renderMessageAndPrompt choices message =
    li []
        [ renderMessage message.author message.content
        , renderPrompt message choices
        ]


renderMessage : String -> String -> Html Msg
renderMessage from message =
    div
        [ class "message al w-75 float-left mt-3 ml-3 py-2" ]
        [ div [ class "mx-3" ]
            [ p [ class "message-from m-0" ]
                [ text from ]
            , p
                [ class "card-text m-0" ]
                [ Markdown.toHtml [ class "content" ] message ]
            ]
        ]


renderPrompt : Content.MessageData -> List String -> Html Msg
renderPrompt message choices =
    if List.length message.choices > 0 then
        div
            [ class "message player w-75 float-right mt-3 mr-3 py-2" ]
            [ div [ class "mx-3" ]
                [ p [ class "message-from m-0" ]
                    [ text (t FromPlayerTeam) ]

                -- we might have some player text in the future?
                --, div [ class "card-text m-0" ]
                --    [ Markdown.toHtml [ class "content" ] message.content ]
                , renderButtons (List.map choiceStringsToButtons message.choices) (choiceHasBeenMade choices message)
                ]
            ]

    else
        text ""


renderButtons : List ButtonInfo -> String -> Html Msg
renderButtons buttonList chosenValue =
    div []
        (List.map
            (\buttonItem ->
                button
                    [ classList
                        [ ( "btn choice-button", True )
                        , ( "btn-primary", chosenValue == "" )
                        , ( "active", chosenValue == buttonItem.action )
                        , ( "disabled", chosenValue /= buttonItem.action && chosenValue /= "" )
                        ]
                    , if chosenValue == "" then
                        onClick (ChoiceButtonClicked buttonItem.action)

                      else
                        Html.Attributes.class ""
                    ]
                    [ text buttonItem.label ]
            )
            buttonList
        )

{-
    Finding player choices is done by looking at the current message.triggeredBy, 
    seeing if that matches one of our current or previous game choices,
    then looping over the choice actions to see if the current game choice list's last element matches 
    one of our choice actions.

    e.g.
        gameData.choices = [ "macaques", "start", "init"]  
    so we've just clicked to select 'macaques' as our animal.

    The message entry for that point in time is 
        message.triggered_by = [ "init|start" ]
        message.choices = [ "macaques|Macaques", "mice|Mice", "fish|Fish" ... ]

    so we transform gameData.choices to ["init" , "init|start", "init|start|macaques"], 
    and iterate over all the combinations and look for matches against [ "init|start|macaques", "init|start|mice", "init|start|fish" ... ]

    If we find a match, we simply take the last element of the string (macaques) and deduce that this must be the value we chose for this message.

-}
choiceHasBeenMade : List String -> Content.MessageData -> String
choiceHasBeenMade playerChoices message =
    -- first choice is 'init', so don't do anything
    -- if the message doesn't give us choices, don't do anything
    if List.length playerChoices <= 1 || List.length message.choices == 0 then
        ""

    else
        let
            -- set of current player choices, e.g. ["init", "init|start", "init|start|macaque"]
            setOfPlayerChoices =
                Set.fromList (GameData.choiceStepsList playerChoices)

            -- list of valid triggers for the current message that match our current or historical player choices
            -- this is normally a single item, but could be multiple
            -- e.g. [ "init|start" ]
            listOfChoicesThatMatch =
                GameData.triggeredByChoicesGetMatches playerChoices message.triggered_by

            -- set of triggers that also have our choice strings attached to them, e.g.
            -- [ "init|start|macaque", "init|start|fish", "init|start|mice" ... ]
            setOfTriggersWithChoiceStringsAttached =
                Set.fromList (triggeredByWithChoiceStrings listOfChoicesThatMatch message.choices)

            -- which player choices match this message?
            setOfMatches =
                Set.intersect setOfPlayerChoices setOfTriggersWithChoiceStringsAttached

            -- take the matching player choice, find the last string (e.g. "macaques") 
            -- and we use that as the value that was clicked by the button
            chosenAction =
                Maybe.withDefault "" (List.head (List.reverse (String.split "|" (Maybe.withDefault "" (List.head (Set.toList setOfMatches))))))

            result =
                if Set.isEmpty setOfMatches then
                    ""

                else
                    chosenAction

            -- debugger =
            --    Debug.log "SETS" (Debug.toString playerChoices ++ " TRIGGERS for " ++ message.basename ++ " " ++ Debug.toString (triggeredByWithChoiceStrings playerChoices message.choices))
        in
        result



-- creates a new triggeredBy list which has all the choice combinations added


triggeredByWithChoiceStrings : List String -> List String -> List String
triggeredByWithChoiceStrings triggeredBy choices =
    List.Extra.lift2 (++) triggeredBy (List.map getChoiceAction choices)


getChoiceAction : String -> String
getChoiceAction choiceString =
    let
        action =
            case List.head (String.indexes "|" choiceString) of
                Nothing ->
                    choiceString

                Just val ->
                    String.left val choiceString
    in
    "|" ++ action
