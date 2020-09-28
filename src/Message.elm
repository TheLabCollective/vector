module Message exposing (Msg(..))

import Browser
import Url


type Msg
    = UrlChanged Url.Url
    | LinkClicked Browser.UrlRequest
    | ChoiceButtonClicked String
    | TeamChosen String
    | NoOp
