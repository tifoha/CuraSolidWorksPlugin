// Copyright (c) 2019 Ultimaker B.V.
// CuraSolidWorksPlugin is released under the terms of the AGPLv3 or higher.

import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1

import UM 1.2 as UM
import Cura 1.0 as Cura

UM.Dialog
{
    id: base
    width: Math.round(Screen.width * 0.8)
    minimumWidth: Math.round(600 * screenScaleFactor)

    height: Math.round(Screen.height * 0.8)
    minimumHeight: Math.round(400 * screenScaleFactor)

    title: catalog.i18nc("@title:window", "How to install Cura SolidWorks macro")

    property var currentStepIndex: 0

    onVisibilityChanged:
    {
        setCurrentStepIndex(0);
    }

    function setCurrentStepIndex(index)
    {
        currentStepIndex = index;
        for (var i = 0; i < stepModel.count; ++i)
        {
            const activated = i == currentStepIndex;
            stepModel.get(i).activated = activated;
            animation.source = "macro/tutorial/" + stepModel.get(currentStepIndex).gif_file_name;
            animationSlider.to = animation.frameCount;
            animationSlider.value = animation.currentFrame;
            animation.playing = true;
        }
    }

    Row
    {
        anchors.fill: parent
        spacing: UM.Theme.getSize("default_margin").width

        UM.I18nCatalog { id: catalog; name: "SolidWorksPlugin" }

        // Left panel: step list
        Column
        {
            id: stepsColumn
            width: Math.round(base.width / 6)
            height: parent.height
            spacing: UM.Theme.getSize("default_margin").height

            Label
            {
                text: catalog.i18nc("@description:label", "Steps:")
                wrapMode: Text.WordWrap
                font: UM.Theme.getFont("large")
            }

            ListModel
            {
                id: stepModel

                ListElement {
                    text: "Start SolidWorks"
                    description: "Start SolidWorks 2016/2017 and make sure that you have a document open."
                    gif_file_name: "1_start_solidworks.gif"
                    activated: false
                }
                ListElement {
                    text: "Open 'Customize' Dialog"
                    description: "Select 'Customize' on the menu bar and open the 'Customize' dialog."
                    gif_file_name: "2_open_customize_dialog.gif"
                    activated: false
                }
                ListElement {
                    text: "Switch to 'Macro'"
                    description: "- Switch to 'Commands'\n- Choose 'Macro'"
                    gif_file_name: "3_switch_to_macro.gif"
                    activated: false
                }
                ListElement {
                    text: "Add New Macro Button"
                    description: "- Trag and drop the 'New Macro Button' icon onto the toolbar\n- Provide the Macro file location and an icon for it"
                    gif_file_name: "4_add_new_macro_button.gif"
                    activated: false
                }
                ListElement {
                    text: "Done!"
                    description: "- Now you have your 'Export model to Cura' button!"
                    gif_file_name: "5_done.gif"
                    activated: false
                }
            }

            Repeater
            {
                model: stepModel

                Label
                {
                    width: stepsColumn.width
                    text: String(model.index + 1) + ". " + catalog.i18nc("@title:label", model.text)
                    wrapMode: Text.WordWrap
                    font.bold: model.activated

                    MouseArea
                    {
                        anchors.fill: parent
                        onClicked:
                        {
                            base.setCurrentStepIndex(model.index);
                        }
                    }
                }
            }

            Button
            {
                id: getMacroAndIconLocationButton
                width: stepsColumn.width
                height: UM.Theme.getSize("button").height
                text: catalog.i18nc("@action:button", "Open the directory\nwith macro and icon")
                onClicked:
                {
                    manager.openMacroAndIconDirectory();
                }
            }
        }

        // Right panel: instructions + animated GIF
        ColumnLayout
        {
            id: infoColumn
            width: base.width - stepsColumn.width - UM.Theme.getSize("default_margin").width * 3
            height: parent.height
            spacing: UM.Theme.getSize("default_margin").height

            Label
            {
                Layout.fillWidth: true
                text: catalog.i18nc("@description:label", "Instructions:")
                wrapMode: Text.WordWrap
                font: UM.Theme.getFont("large")
            }

            Label
            {
                id: tutorialText
                Layout.fillWidth: true
                text: catalog.i18nc("@description:label", stepModel.get(currentStepIndex).description)
                wrapMode: Text.WordWrap
                font: UM.Theme.getFont("default")
            }

            AnimatedImage
            {
                id: animation
                Layout.fillWidth: true
                Layout.fillHeight: true
                fillMode: Image.PreserveAspectFit
                source: "macro/tutorial/" + stepModel.get(currentStepIndex).gif_file_name

                onSourceChanged:
                {
                    animationSlider.to = frameCount;
                    animationSlider.value = currentFrame;
                }
            }

            RowLayout
            {
                Layout.fillWidth: true
                spacing: UM.Theme.getSize("default_margin").width

                Button
                {
                    id: playPauseButton
                    text:
                    {
                        if (!animation.playing)
                        {
                            return catalog.i18nc("@action:playpause", "Play");
                        }
                        else
                        {
                            return catalog.i18nc("@action:playpause", "Pause");
                        }
                    }

                    onClicked:
                    {
                        var previousFrame = animation.currentFrame;
                        const wasPaused = !animation.playing;
                        animation.playing = !animation.playing;
                        if (wasPaused)
                        {
                            animation.currentFrame = previousFrame;
                        }
                    }
                }

                Slider
                {
                    id: animationSlider
                    Layout.fillWidth: true
                    orientation: Qt.Horizontal
                    stepSize: 1
                    from: 0
                    value: animation.currentFrame

                    property var wasPlaying: true

                    onValueChanged:
                    {
                        wasPlaying = animation.playing;
                        animation.currentFrame = value;
                        animation.playing = wasPlaying;
                    }

                    onPressedChanged:
                    {
                        if (pressed)
                        {
                            wasPlaying = animation.playing;
                            animation.playing = false;
                        }
                        animation.playing = wasPlaying;
                    }
                }

                Binding
                {
                    target: animationSlider
                    property: "value"
                    value: animation.currentFrame
                }
            }
        }
    }

    rightButtons: [
        Button
        {
            id: prevStepButton
            text: catalog.i18nc("@action:button", "Previous Step")
            enabled: base.currentStepIndex > 0
            onClicked:
            {
                base.setCurrentStepIndex(base.currentStepIndex - 1);
            }
        },
        Button
        {
            id: nextStepButton
            text:
            {
                if (base.currentStepIndex + 1 == stepModel.count)
                {
                    return catalog.i18nc("@action:button", "Done")
                }
                else
                {
                    return catalog.i18nc("@action:button", "Next Step")
                }
            }
            onClicked:
            {
                if (base.currentStepIndex + 1 == stepModel.count)
                {
                    close();
                }
                else
                {
                    base.setCurrentStepIndex(base.currentStepIndex + 1);
                }
            }
        },
        Button
        {
            id: closeButton
            text: catalog.i18nc("@action:button", "Close")
            onClicked:
            {
                close();
            }
            enabled: true
        }
    ]
}
