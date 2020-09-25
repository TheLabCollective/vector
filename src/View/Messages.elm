module View.Messages exposing (view)

import Content
import Copy.Keys exposing (Key(..))
import Copy.Text exposing (t)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Message exposing (Msg(..))
import Route exposing (Route(..))


type From
    = AL
    | PlayerTeam

stringToFrom : String -> From
stringToFrom fromString = 
    case fromString of 
        "AL" -> 
            AL
        _   ->
            PlayerTeam


type alias ButtonInfo =
    { label : String
    , action : String
    }

choiceStringsToButtons: String -> ButtonInfo
choiceStringsToButtons buttonString = 
    { label = buttonString, action = "#" }


view : Dict String Content.MessageData -> Html Msg
view messagesDict =
    ul [ class "message-list p-0" ]
    (List.map listItem (Dict.values messagesDict))
{- 
    [ renderMessage AL "Which animal would you like to use?" []
    , renderMessage PlayerTeam "We'd like to choose:" [ { label = "Mouse", action = "#" }, { label = "Monkey", action = "#" }, { label = "Fish", action = "#" } ]
    , renderMessage AL "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum." []
    ]
-}
    

listItem : Content.MessageData -> Html Msg
listItem message = 
    let 
        buttonList = 
            List.map choiceStringsToButtons message.choices
    in 
    renderMessage (stringToFrom message.author) message.content buttonList


renderMessage : From -> String -> List ButtonInfo -> Html Msg
renderMessage from message buttons =
    if from == AL then
        li
            [ class "message al w-75 float-left mt-3 ml-5 py-2" ]
            [ div [ class "ml-3" ]
                [ p [ class "message-from m-0" ]
                    [ text (t FromAL) ]
                , p
                    [ class "card-text m-0" ]
                    [ text message ]
                ]
            ]

    else
        li
            [ class "message player w-75 float-right mt-3 mr-5 py-2" ]
            [ div [ class "ml-3" ]
                [ p [ class "message-from m-0" ]
                    [ text (t FromPlayerTeam) ]
                , p [ class "card-text m-0" ]
                    [ text message ]
                , renderButtons buttons
                ]
            ]


renderButtons : List ButtonInfo -> Html Msg
renderButtons buttonList =
    div []
        (List.map
            (\buttonItem -> button [ class "btn btn-primary choice-button" ] [ text buttonItem.label ])
            buttonList
        )