module View.Desktop exposing ( view, renderWrapperWithNav)

import Html exposing (..)
import Html.Attributes exposing (..)
import Message exposing (Msg(..))
import Heroicons.Outline exposing (mail, documentText, chatAlt, hashtag)
import Route exposing (Route(..))
import Copy.Keys exposing (Key(..))
import Copy.Text exposing (t)

iconSize : Int 
iconSize = 24

view : Route -> Html Msg
view pageRoute =
    div [] [
        renderWrapperWithNav pageRoute [text "my desktop"]
    ]

renderWrapperWithNav : Route -> List (Html Msg) -> Html Msg
renderWrapperWithNav pageRoute elements  =
    div [ class "container" ] [
        div [ class "row" ] [
            div [ class "col-sm-auto" ] [
                renderTeamInformation,
                renderNavLinks pageRoute
            ],
            div [ class "col" ] elements
        ]
    ]

renderNavLinks : Route -> Html Msg
renderNavLinks pageRoute =
    nav [ class "nav flex-column nav-pills" ]
        [ a [ class "nav-link", href (Route.toString Route.Documents) ] [ 
            documentText [ width iconSize, height iconSize], 
            text " ", 
            text (t NavDocuments), 
            span [ class "badge badge-secondary" ] [ text "4" ]
        ],
        a [ class "nav-link active", href (Route.toString Route.Emails) ] [ 
            mail [ width iconSize, height iconSize], 
            text " ", 
            text (t NavEmails) 
        ],
        a [ class "nav-link", href (Route.toString Route.Messages) ] [ 
            chatAlt [ width iconSize, height iconSize], 
            text " ", 
            text (t NavMessages)  
        ],
        a [ class "nav-link", href (Route.toString Route.Social) ] [ 
            hashtag [ width iconSize, height iconSize], 
            text " ", 
            text (t NavSocial) 
            ]
        ]

renderTeamInformation : Html Msg
renderTeamInformation = 
    div [] [
        div [ class "card" ] [
            div [ class "card-body" ] [
                h5 [class "card-title"] [ text "Team Elm" ],
                p [ class "card-text"] [ text "tree picture here"]
            ]
        ]
    ]