module View.Desktop exposing (renderWrapperWithNav, view)

import Copy.Keys exposing (Key(..))
import Copy.Text exposing (t)
import GameData exposing (ContentLength, GameData)
import Heroicons.Outline exposing (chatAlt, documentText, hashtag, mail, userCircle)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, targetValue)
import Json.Decode as Json
import Message exposing (Msg(..))
import Route exposing (Route(..))
import Svg.Attributes


view : GameData -> Route -> ContentLength -> Html Msg
view gameData pageRoute notifications =
    case String.left 1 gameData.teamName of
        "?" ->
            renderLoginPage gameData

        {-
           When the team name consists of a ? or is prefixed with a ?, we should show the login box.

           A ? prefix on teamname value is used so that we can change the model's data value in the
           <select> 'onChange' event without instantly navigating away from this page (which is a weird user experience)
           - instead, they click on the login <button> which removes the '?' prefix from the teamName
        -}
        _ ->
            div []
                [ renderWrapperWithNav gameData pageRoute notifications [ text "my desktop" ]
                ]


renderWrapperWithNav : GameData -> Route -> ContentLength -> List (Html Msg) -> Html Msg
renderWrapperWithNav gameData pageRoute notifications elements =
    div [ class "container-fluid " ]
        [ div [ class "row desktop" ]
            [ div [ class "col-md-2 d-none d-md-block" ]
                [ div [ class "sticky-top" ]
                    [ renderTeamInformation gameData.teamName
                    , renderNavLinks pageRoute notifications
                    ]
                ]
            , div [ class "order-last d-md-none" ]
                [ renderMobileNavLinks pageRoute notifications
                ]
            , div [ class "col-md-8 content" ] elements
            ]
        ]


loginOption : String -> Html Msg
loginOption login =
    option [ value ("?" ++ String.trim login) ] [ text login ]


renderLoginPage : GameData -> Html Msg
renderLoginPage gameData =
    div [ class "container desktop" ]
        [ div [ class "v-centred" ]
            [ div [ class "sign-in" ]
                [ userCircle []
                , h1 [] [ text "Please login" ]
                , let
                    teamNamesList =
                        String.split "," (t TeamNames)
                  in
                  select
                    [ on "change" (Json.map TeamChosen targetValue)
                    , class "form-control"
                    , value gameData.teamName
                    ]
                    (List.map loginOption teamNamesList)
                , button
                    [ class "btn btn-primary btn-block"
                    , let
                        teamName =
                            if gameData.teamName == "?" then
                                gameData.teamName

                            else
                                String.dropLeft 1 gameData.teamName
                      in
                      onClick (TeamChosen teamName)
                    ]
                    [ text "Login" ]
                ]
            ]
        ]


renderNavLinks : Route -> ContentLength -> Html Msg
renderNavLinks pageRoute notifications =
    nav [ class "nav flex-column nav-pills" ]
        [ a
            [ classList
                [ ( "nav-link", True )
                , ( "active", pageRoute == Route.Messages )
                ]
            , href (Route.toString Route.Messages)
            ]
            [ chatAlt [ Svg.Attributes.class "nav-icon" ]
            , text (t NavMessages)
            , if notifications.messages > 0 then
                span [ class "badge badge-warning" ] [ text (String.fromInt notifications.messages) ]

              else
                text ""
            ]
        , a
            [ classList
                [ ( "nav-link", True )
                , ( "active", Route.isDocumentRoute pageRoute )
                ]
            , href (Route.toString Route.Documents)
            ]
            [ documentText [ Svg.Attributes.class "nav-icon" ]
            , text (t NavDocuments)
            , text " "
            , if notifications.documents > 0 then
                span [ class "badge badge-warning" ] [ text (String.fromInt notifications.documents) ]

              else
                text ""
            ]
        , a
            [ classList
                [ ( "nav-link", True )
                , ( "active", Route.isEmailRoute pageRoute )
                ]
            , href (Route.toString Route.Emails)
            ]
            [ mail [ Svg.Attributes.class "nav-icon" ]
            , text (t NavEmails)
            , if notifications.emails > 0 then
                span [ class "badge badge-warning" ] [ text (String.fromInt notifications.emails) ]

              else
                text ""
            ]
        , a
            [ classList
                [ ( "nav-link", True )
                , ( "active", pageRoute == Route.Social )
                ]
            , href (Route.toString Route.Social)
            ]
            [ hashtag [ Svg.Attributes.class "nav-icon" ]
            , text (t NavSocial)
            , if notifications.social > 0 then
                span [ class "badge badge-warning" ] [ text (String.fromInt notifications.social) ]

              else
                text ""
            ]
        ]


renderMobileNavLinks : Route -> ContentLength -> Html Msg
renderMobileNavLinks pageRoute notifications =
    nav [ class "nav nav-pills mobile-nav fixed-bottom" ]
        [ a
            [ classList
                [ ( "nav-link", True )
                , ( "active", pageRoute == Route.Messages )
                ]
            , class "mobile-nav-item"
            , href (Route.toString Route.Messages)
            ]
            [ chatAlt [ Svg.Attributes.class "mobile-nav-icon" ]
            , div [] [ text (t NavMessages) ]
            , if notifications.messages > 0 then
                span [ class "badge badge-warning badge-mobile" ] [ text (String.fromInt notifications.messages) ]

              else
                text ""
            ]
        , a
            [ classList
                [ ( "nav-link", True )
                , ( "active", Route.isDocumentRoute pageRoute )
                ]
            , class "mobile-nav-item"
            , href (Route.toString Route.Documents)
            ]
            [ documentText [ Svg.Attributes.class "mobile-nav-icon" ]
            , div [] [ text (t NavDocuments) ]
            , if notifications.documents > 0 then
                span [ class "badge badge-warning badge-mobile" ] [ text (String.fromInt notifications.documents) ]

              else
                text ""
            ]
        , a
            [ classList
                [ ( "nav-link", True )
                , ( "active", Route.isEmailRoute pageRoute )
                ]
            , class "mobile-nav-item"
            , href (Route.toString Route.Emails)
            ]
            [ mail [ Svg.Attributes.class "mobile-nav-icon" ]
            , div [] [ text (t NavEmails) ]
            , if notifications.emails > 0 then
                span [ class "badge badge-warning badge-mobile" ] [ text (String.fromInt notifications.emails) ]

              else
                text ""
            ]
        , a
            [ classList
                [ ( "nav-link", True )
                , ( "active", pageRoute == Route.Social )
                ]
            , class "mobile-nav-item"
            , href (Route.toString Route.Social)
            ]
            [ hashtag [ Svg.Attributes.class "mobile-nav-icon" ]
            , div [] [ text (t NavSocial) ]
            , if notifications.social > 0 then
                span [ class "badge badge-warning badge-mobile" ] [ text (String.fromInt notifications.social) ]

              else
                text ""
            ]
        ]


renderTeamInformation : String -> Html Msg
renderTeamInformation teamName =
    div []
        [ div [ class "card" ]
            [ div [ class "card-body" ]
                [ h5 [ class "card-title" ] [ text ("Team " ++ teamName) ]
                , p [ class "card-text" ] [ text "team picture here" ]
                ]
            ]
        ]
