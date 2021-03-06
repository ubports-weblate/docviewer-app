/*
 * Copyright (C) 2014-2016 Canonical, Ltd.
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
import Ubuntu.Components.Popups 1.3
import QtQuick.Layouts 1.1

Dialog {
    id: goToPageDialog
    objectName:"PdfViewGotoDialog"

    title: i18n.tr("Go to page")
    text: i18n.tr("Choose a page between 1 and %1").arg(pdfView.count)

    TextField {
        id: goToPageTextField
        objectName:"goToPageTextField"

        width: parent.width

        hasClearButton: true
        inputMethodHints: Qt.ImhFormattedNumbersOnly
        validator: IntValidator{ bottom: 1; top: pdfView.count }

        onAccepted: goToPage()
        Component.onCompleted: forceActiveFocus()
    }

    RowLayout {
        anchors {
            left: parent.left
            right: parent.right
            margins: units.gu(-1)
        }

        Button {
            text: i18n.tr("Cancel")
            onClicked: PopupUtils.close(goToPageDialog)
            Layout.fillWidth: true
        }

        Button {
            objectName:"GOButton"
            text: i18n.tr("GO!")
            color: UbuntuColors.green
            Layout.fillWidth: true

            enabled: goToPageTextField.acceptableInput
            onClicked: goToPage()
        }
    }

    function goToPage() {
        pdfView.positionAtIndex((goToPageTextField.text - 1))
        PopupUtils.close(goToPageDialog)
    }
}
