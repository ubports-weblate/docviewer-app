/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors: Anthony Granger <grangeranthony@gmail.com>
 *          Stefano Verzegnassi <stefano92.100@gmail.com>
 */

#include "pdfdocument.h"
#include "pdfimageprovider.h"
#include "pdfthread.h"

#include <poppler/qt5/poppler-qt5.h>
#include <QDebug>
#include <QQmlEngine>
#include <QQmlContext>

PdfDocument::PdfDocument(QAbstractListModel *parent):
    QAbstractListModel(parent)
  , m_path("")
{
    qRegisterMetaType<PdfPagesList>("PdfPagesList");
}

QHash<int, QByteArray> PdfDocument::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[WidthRole] = "width";
    roles[HeightRole] = "height";
    return roles;
}

int PdfDocument::rowCount(const QModelIndex & parent) const
{
    Q_UNUSED(parent)
    return m_pages.count();
}

QVariant PdfDocument::data(const QModelIndex & index, int role) const
{
    if (index.row() < 0 || index.row() > m_pages.count())
        return QVariant();

    const PdfItem &pdfItem = m_pages.at(index.row());

    switch (role) {
    case WidthRole:
        return pdfItem.width();
    case HeightRole:
        return pdfItem.height();
    default:
        return 0;
    }
}

void PdfDocument::setPath(QString &pathName)
{
    if (pathName.isEmpty())
        return;

    m_path = pathName;
    Q_EMIT pathChanged();

    if (!loadDocument(m_path))
        return;

    loadPages();
    loadProvider();
}

bool PdfDocument::loadDocument(QString &pathName)
{
    qDebug() << "Loading document...";

    if (pathName.isEmpty()) {
        qDebug() << "Can't load the document, path is empty.";
        return false;
    }

    m_document = Poppler::Document::load(pathName);

    if (!m_document || m_document->isLocked()) {
        qDebug() << "ERROR : Can't open the document located at " + pathName;
        Q_EMIT error("Can't open the document located at " + pathName);

        delete m_document;
        return false;
    }

    qDebug() << "Document loaded successfully !";

    m_document->setRenderHint(Poppler::Document::Antialiasing, true);
    m_document->setRenderHint(Poppler::Document::TextAntialiasing, true);

    return true;
}

QDateTime PdfDocument::getDocumentDate(QString data)
{
    if (!m_document)
        return QDateTime();

    if (data == "CreationDate" || data == "ModDate")
        return m_document->date(data);
    else
        return QDateTime();
}

QString PdfDocument::getDocumentInfo(QString data)
{
    if (!m_document)
        return QString("");

    if (data == "Title" || data == "Subject" || data == "Author" || data == "Creator" || data == "Producer")
        return m_document->info(data);
    else
        return QString("");
}

bool PdfDocument::loadPages()
{
    qDebug() << "Populating model...";

    m_pages.clear();

    if (!m_document)
        return false;

    PdfThread *pdfThread = new PdfThread();
    pdfThread->setDocument(m_document);

    connect(pdfThread, SIGNAL(resultReady(PdfPagesList)), this, SLOT(_q_populate(PdfPagesList)));
    connect(pdfThread, SIGNAL(finished()), pdfThread, SLOT(deleteLater()));
    pdfThread->start();

    return true;
}

void PdfDocument::_q_populate(PdfPagesList pagesList)
{
    qDebug() << "Number of pages:" << pagesList.count();

    Q_FOREACH (Poppler::Page *page, pagesList) {
        beginInsertRows(QModelIndex(), rowCount(), rowCount());
        m_pages << page;
        endInsertRows();
    }

    qDebug() << "Model has been successfully populated!";
    Q_EMIT pagesLoaded();
}

void PdfDocument::loadProvider()
{
    qDebug() << "Loading image provider...";
    QQmlEngine *engine = QQmlEngine::contextForObject(this)->engine();

    engine->addImageProvider(QLatin1String("poppler"), new PdfImageProvider(m_document));

    qDebug() << "Image provider loaded successfully !";
}

PdfDocument::~PdfDocument()
{
}