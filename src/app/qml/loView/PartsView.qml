/*
 * Copyright (C) 2015, 2016 Stefano Verzegnassi
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.1
import DocumentViewer.LibreOffice 1.0 as LibreOffice

// TODO: If we'll be planning to reorganise QML components, consider to provide
// delegates in some separate documents.

ListView {
    id: view
    objectName: "view"
    clip: true

    property bool expanded: true

    orientation: ListView.Vertical

    // used in vertical mode
    property bool isWide: width > units.gu(24)

    currentIndex: view.model ? loView.currentPart : -1
    
    // Ensure that items next to current item are always visible (and then
    // clickable) without the need of extra interaction from the user.
    // FIXME: If the current item is out the visible area, the 'highlightMove'
    // animation shouldn't be fully performed, but applied from the first visible
    // item instead. This actually seems to be a limitation of ListView itself.
    highlightRangeMode: ListView.ApplyRange
    highlightMoveDuration: UbuntuAnimation.FastDuration
    preferredHighlightBegin: internal.isVerticalView ? (view.height - internal.verticalItemHeight) * 0.5
                                                     : (view.width - internal.horizontalItemWidth) * 0.5
    preferredHighlightEnd: internal.isVerticalView ? (view.height - internal.verticalItemHeight) * 0.5
                                                   : (view.width - internal.horizontalItemWidth) * 0.5

    delegate: internal.isVerticalView ? verticalDelegate : horizontalDelegate

    Component.onCompleted: {
        // WORKAROUND: Fix for wrong grid unit size
        flickDeceleration = 1500 * units.gridUnit / 8
        maximumFlickVelocity = 2500 * units.gridUnit / 8
    }

    Component {
        id: verticalDelegate

        ListItem {
            id: delegate

            // Defined at the end of this document
            width: internal.verticalItemWidth
            height: internal.verticalItemHeight

            color: (loView.currentPart === model.index) ? theme.palette.selected.background
                                                        : "transparent"

            onClicked: internal.delegate_onClicked(model.index)

            /*** UITK 1.3 specs: Three slot layout (B-A-C)
              ________________________________________
             |   |                                |   |
             | B |               A                | C |
             |___|________________________________|___|

            *********************************************/

            ListItemLayout {
                id: listItemLayout
                anchors.fill: parent

                /* UITK 1.3 specs: Slot B */
                Item {
                    SlotsLayout.position: SlotsLayout.Leading
                    height: parent.height; width: height
                    BorderImage {
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: units.gu(0.25)
                            horizontalCenterOffset: units.gu(0.25)
                        }
                        width: vThumbnail.paintedWidth + units.gu(1.5)
                        height: vThumbnail.paintedHeight + units.gu(1.5)
                        source: "graphics/dropshadow.sci"
                    }
                    Image {
                        id: vThumbnail
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        // Do not store a cache of the thumbnail, so that we don't show
                        // thumbnails of a previously loaded document.
                        cache: false
                        source: "image://lok/part/%1".arg(model.index)
                    }
                }

                /* UITK 1.3 specs: Slot A */
                title {
                    wrapMode: Text.WordWrap
                    text: model.name
                    visible: view.isWide
                    color: (loView.currentPart === model.index) ? theme.palette.selected.backgroundText
                                                                : theme.palette.normal.backgroundText
                }

                /* UITK 1.3 specs: Slot C */
                Label {
                    SlotsLayout.position: SlotsLayout.Trailing

                    text: model.index + 1
                    color: (loView.currentPart === model.index) ? theme.palette.selected.backgroundText
                                                                : theme.palette.normal.backgroundText
                }
            }
        }
    }

    Component {
        id: horizontalDelegate

        ListItem {
            id: delegate

            // Defined at the end of this document
            width: internal.horizontalItemWidth
            height: internal.horizontalItemHeight

            color: (loView.currentPart === model.index) ? theme.palette.selected.background
                                                        : "transparent"

            onClicked: internal.delegate_onClicked(model.index)

            ColumnLayout {
                anchors {
                    fill: parent
                    topMargin: units.gu(1)
                    leftMargin: units.gu(2)
                    rightMargin: units.gu(2)
                }
                spacing: units.gu(0.5)

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    BorderImage {
                        anchors {
                            centerIn: parent
                            verticalCenterOffset: units.gu(0.25)
                            horizontalCenterOffset: units.gu(0.25)
                        }
                        width: hThumbnail.paintedWidth + units.gu(1.5)
                        height: hThumbnail.paintedHeight + units.gu(1.5)
                        source: "graphics/dropshadow.sci"
                    }
                    Image {
                        id: hThumbnail
                        anchors.fill: parent
                        fillMode: Image.PreserveAspectFit
                        // Do not store a cache of the thumbnail, so that we don't show
                        // thumbnails of a previously loaded document.
                        cache: false
                        source: "image://lok/part/%1".arg(model.index)
                    }
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
                    text: model.index + 1
                    color: (loView.currentPart === model.index) ? theme.palette.selected.backgroundText
                                                                : theme.palette.normal.backgroundText
                }
            }
        }
    }

    QtObject {
        id: internal

        readonly property bool isVerticalView: view.orientation == ListView.Vertical

        // Vertical delegate size
        readonly property int verticalItemWidth: view.width
        readonly property int verticalItemHeight: units.gu(16)

        // Horizontal delegate size
        readonly property int horizontalItemWidth: horizontalItemHeight
        readonly property int horizontalItemHeight: view.height

        function delegate_onClicked(index) {
            loView.currentPart = index

            // Check if the view has been included in a nested page (e.g.
            // bottomEdge). If so, close that page and return to the
            // main viewer.
            if (view.hasOwnProperty("belongsToNestedPage"))
                pageStack.pop();
        }
    }

    Scrollbar { flickableItem: view; parent: view.parent }
}
