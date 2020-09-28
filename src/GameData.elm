module GameData exposing (GameData, filterMessages, init)

import Content exposing (MessageData)
import Dict exposing (Dict)


type alias GameData =
    { choices : List String }


init : GameData
init =
    -- Start button on intro screen will eventually set this "init"
    { choices = [ "init" ] }


triggeredByChoices : String -> List String -> Bool
triggeredByChoices currentChoices triggeredByList =
    -- "init" only for the initial content after that all trigger strings start with "start"
    List.member (String.replace "init|" "" currentChoices) triggeredByList


filterMessages : Dict String MessageData -> List String -> Dict String MessageData
filterMessages allMessages choices =
    let
        choiceString =
            -- The game data choices get added to head of list, we want to match that in reverse.
            String.join "|" (List.reverse choices)
    in
    Dict.filter (\key value -> triggeredByChoices choiceString value.triggered_by) allMessages