module TEA.Components.Dropdown exposing (Msg, Model, update, view, init)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


type Msg a
    = Toggle
    | Close
    | Select a


type alias Model a =
    { isOpen : Bool
    , display : a -> String
    , placeholder : String
    , selected : Maybe a
    , options : List a
    }


init : (a -> String) -> String -> Maybe a -> List a -> Model a
init =
    Model False


update : Msg a -> Model a -> Model a
update msg model =
    case msg of
        Toggle ->
            { model | isOpen = not model.isOpen }

        Close ->
            { model | isOpen = False }

        Select x ->
            { model
                | isOpen = False
                , selected = Just x
            }


option : String -> a -> Html (Msg a)
option label x =
    button [ class "dropdown-item", onClick (Select x) ]
        [ text label ]


mainText : Model a -> Html (Msg a)
mainText model =
    Maybe.map model.display model.selected
        |> Maybe.withDefault model.placeholder
        |> text


view : Model a -> Html (Msg a)
view model =
    div
        [ class <|
            "dropdown"
                ++ if model.isOpen then
                    " show"
                   else
                    ""
        ]
        [ button [ class "btn btn-secondary dropdown-toggle", onClick Toggle ]
            [ mainText model ]
        , div [ class "dropdown-menu" ]
            (List.map (\x -> option (model.display x) x) model.options)
        ]
