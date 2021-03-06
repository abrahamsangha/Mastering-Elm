module TEA.Kit.Happenings.View exposing (..)

import Html exposing (..)
import Html.Events as Events
import Html.Attributes as Attributes
import Json.Decode as Decode
import Date
import Time exposing (Time)
import TEA.Kit.Happenings.Model as Model exposing (Model)
import TEA.Kit.Happenings.Msg as Msg exposing (Msg)
import TEA.Components.Button as Button
import TEA.Components.Css.Packages as Css


{-
   This is the top level View for our app. Everything that will be displayed on
   screen will be in this view function. All subviews will need to be called from
   this function.
-}


view : Model -> Html Msg
view { records, annotation } =
    div
        [ Attributes.style
            [ ( "background", "center top no-repeat url('/Assets/noteTaker.jpg')" )
            , ( "width", "100%" )
            , ( "height", "100%" )
            ]
        ]
        [ Css.bootstrap
        , wrap
            [ header
            , row <|
                ul
                    [ Attributes.class "list-group col-lg-12"
                    , Attributes.style
                        [ ( "height", "20rem" )
                        , ( "margin-bottom", "3.5rem" )
                        , ( "overflow-y", "scroll" )
                        ]
                    ]
                    (List.map record records)
              -- TODO: Wireup dropdown
            , row (addControl (Just Model.NewKnocks) annotation)
            , row <|
                small
                    [ Attributes.style
                        [ ( "transform", "translateX(-25px)" )
                        , ( "width", "13rem" )
                        , ( "height", "5rem" )
                        , ( "overflow", "hidden" )
                        ]
                    ]
                <|
                    [ text "Current time: "
                      -- TODO: Display the current time here
                      -- If the time is not yet available, print "Loading..."
                    , br [] []
                    ]
                        ++ stats records
            ]
        ]


stats : List Model.Record -> List (Html msg)
stats records =
    -- TODO: Compute the stats and display them here
    [ text "Total knocks: 0"
    , br [] []
    , text "Cold spots: 0"
    , br [] []
    , text "Levitating objects: "
    ]


addControl : Maybe Model.NewHappening -> String -> Html Msg
addControl selected annotation =
    -- TODO: wireupdropdown
    let
        input_ placeholder =
            input
                [ Events.onInput Msg.Newannotation
                , Attributes.class "form-control"
                , Attributes.value annotation
                , Attributes.placeholder placeholder
                ]
                []

        new =
            newHappening selected annotation
    in
        div
            ((case new of
                Just happening ->
                    [ onKeyUp
                        (\key ->
                            if key == 13 then
                                Msg.Add happening
                            else
                                Msg.NoOp
                        )
                    ]

                _ ->
                    []
             )
                ++ [ Attributes.class "input-group"
                   , Attributes.style [ ( "background", "rgba(0,0,0,0.1)" ), ( "margin", "10px -3rem" ), ( "width", "36rem" ) ]
                   ]
            )
            [ span [ Attributes.class "input-group-addon" ]
                [ text "Add a new happening" ]
              -- TODO: Wireup dropdown
            , case selected of
                Just (Model.NewKnocks) ->
                    input_ "How many?"

                Just (Model.NewFloating) ->
                    input_ "What object?"

                _ ->
                    text ""
            , case new of
                Just happening ->
                    span [ Attributes.class "input-group-btn" ]
                        [ Button.view (Msg.Add happening) "Add" ]

                _ ->
                    text ""
            ]


row : Html msg -> Html msg
row child =
    div [ Attributes.class "row" ] [ child ]


newHappening : Maybe Model.NewHappening -> String -> Maybe Model.Happening
newHappening selectedHappening annotation =
    case ( selectedHappening, annotation ) of
        ( Just (Model.NewKnocks), count ) ->
            case Decode.decodeString Decode.int count of
                Ok count_ ->
                    Just (Model.Knocks count_)

                _ ->
                    Nothing

        ( Just (Model.NewColdspot), _ ) ->
            Just Model.Coldspot

        ( Just (Model.NewFloating), object ) ->
            if object == "" then
                Nothing
            else
                Just (Model.Floating (Model.Object object))

        _ ->
            Nothing


record : Model.Record -> Html Msg
record (( happening, time ) as record) =
    li [ Attributes.class "list-group-item" ]
        [ case happening of
            Model.Knocks knocks ->
                text (toString knocks ++ " knocks, heard at " ++ formatTime time)

            Model.Coldspot ->
                text ("Cold spot felt at " ++ formatTime time)

            Model.Floating (Model.Object object) ->
                text ("Levitating " ++ String.toLower object ++ " seen at " ++ formatTime time)
        , span
            [ Events.onClick (Msg.Delete record)
            , Attributes.style [ ( "float", "right" ), ( "cursor", "pointer" ) ]
            , Attributes.class "badge badge-default badge-pill"
            ]
            [ text "X" ]
        ]


formatTime : Time -> String
formatTime time =
    if time == 0 then
        "Loading.."
    else
        let
            date =
                Date.fromTime time

            leadingZero x =
                (if x < 10 then
                    "0"
                 else
                    ""
                )
                    ++ toString x
        in
            leadingZero (Date.hour date % 12)
                ++ ":"
                ++ leadingZero (Date.minute date)
                ++ ":"
                ++ leadingZero (Date.second date)
                ++ if Date.hour date <= 12 then
                    "AM"
                   else
                    "PM"


wrap : List (Html Msg) -> Html Msg
wrap =
    div
        [ Attributes.class "container"
        , Attributes.style
            [ ( "max-width", "30rem" )
            , ( "padding-top", "14rem" )
            , ( "padding-bottom", "1rem" )
            , ( "transform", "translateX(-10px)" )
            ]
        ]


header : Html Msg
header =
    div [ Attributes.class "header clearfix" ]
        [ h3
            [ Attributes.class "text-muted"
            , Attributes.style [ ( "text-align", "center" ) ]
            ]
            [ text "Happenings at 52160 Willow St." ]
        ]


onKeyUp : (Int -> msg) -> Attribute msg
onKeyUp tagger =
    Events.on "keyup" (Decode.map tagger Events.keyCode)
