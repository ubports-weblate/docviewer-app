/*
 * Copyright (C) 2015 Canonical Ltd.
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
 */

#ifndef LOPARTSMODEL_H
#define LOPARTSMODEL_H

#include <QAbstractListModel>

class LODocument;

class LOPartEntry
{
public:
    QString name;
    int index = 0;
};

class LOPartsModel : public QAbstractListModel
{
    Q_OBJECT
    Q_DISABLE_COPY(LOPartsModel)
    Q_PROPERTY(LODocument* document READ document WRITE setDocument NOTIFY documentChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    enum Roles {
        NameRole,
        IndexRole
    };

    explicit LOPartsModel(QAbstractListModel *parent = 0);
    ~LOPartsModel();

    LODocument* document() { return m_document; }
    void setDocument(LODocument* document);

    QHash<int, QByteArray> roleNames() const;

    int rowCount(const QModelIndex & parent = QModelIndex()) const;
    QVariant data(const QModelIndex & index, int role = Qt::DisplayRole) const;

    Q_INVOKABLE QVariantMap get(int index) const;

Q_SIGNALS:
    void documentChanged();
    void countChanged();

private slots:
    void fillModel();

private:
    LODocument* m_document;
    QList<LOPartEntry> m_entries;
};

#endif // LOPARTSMODEL_H
