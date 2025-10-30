#include "filepicker.h"
#include <QFile>

#ifndef WASM_PLATFORM

FilePicker::FilePicker(QObject *parent) : QObject(parent) {}

void FilePicker::classBegin()
{
    QQmlEngine *engine = qmlEngine(this);
    if (!engine) return;
    QQmlComponent component(engine, this);
    QByteArray data = "import QtQuick; import QtQuick.Dialogs; FileDialog {}";
    component.setData(data, QUrl());
    m_fileDialog = component.create();
    m_fileDialog->setParent(this);

    connect(m_fileDialog, SIGNAL(fileModeChanged()), this, SIGNAL(fileModeChanged()));
    connect(m_fileDialog, SIGNAL(titleChanged()), this, SIGNAL(titleChanged()));
    connect(m_fileDialog, SIGNAL(acceptLabelChanged()), this, SIGNAL(acceptLabelChanged()));
    connect(m_fileDialog, SIGNAL(currentFolderChanged()), this, SIGNAL(currentFolderChanged()));
    connect(m_fileDialog, SIGNAL(defaultSuffixChanged()), this, SIGNAL(defaultSuffixChanged()));
    connect(m_fileDialog, SIGNAL(selectedFileChanged()), this, SIGNAL(selectedFileChanged()));
    connect(m_fileDialog, SIGNAL(nameFiltersChanged()), this, SIGNAL(nameFiltersChanged()));

    connect(m_fileDialog, SIGNAL(accepted()), this, SLOT(fileHandler()));
    connect(m_fileDialog, SIGNAL(rejected()), this, SIGNAL(closed()));

    /*
    connect(this, &FilePicker::fileModeChanged,
            this, [this]{ QQmlProperty::write(m_fileDialog, "fileMode", m_fileMode); });
    connect(this, &FilePicker::titleChanged,
            this, [this]{ QQmlProperty::write(m_fileDialog, "title", m_title); });
    connect(this, &FilePicker::acceptLabelChanged,
            this, [this]{ QQmlProperty::write(m_fileDialog, "acceptLabel", m_acceptLabel); });
    connect(this, &FilePicker::currentFolderChanged,
            this, [this]{ QQmlProperty::write(m_fileDialog, "currentFolder", m_currentFolder); });
    connect(this, &FilePicker::defaultSuffixChanged,
            this, [this]{ QQmlProperty::write(m_fileDialog, "defaultSuffix", m_defaultSuffix); });
    connect(this, &FilePicker::nameFiltersChanged,
            this, [this]{ QQmlProperty::write(m_fileDialog, "nameFilters", m_nameFilters); });
    */
}

void FilePicker::componentComplete() {}

void FilePicker::fileHandler()
{
    switch (fileMode()) {
    case OpenFile: {
        QFile file(selectedFile());
        if (!file.exists()) {
            qDebug() << "файл не существует";
            return;
        }
        if (!file.open(QIODevice::ReadOnly)) {
            qDebug() << "недостаточно прав для открытия файла";
            return;
        }
        QByteArray data = file.readAll();
        file.close();
        if (data.isEmpty()) {
            qDebug() << "файл пуст";
            return;
        }
        emit fileReaded(data);
        emit closed();
    }
        break;
    case SaveFile: {
        QFile file(selectedFile());
        if (!file.open(QIODevice::WriteOnly)) {
            qDebug() << "недостаточно прав для открытия файла";
            return;
        }
        file.close();
        emit closed();
    }
        break;
    default:
        break;
    }
}

#else

FilePicker::FilePicker(QObject *parent) : QObject(parent) {}

void FilePicker::setFileMode(int fileMode)
{
    if (fileMode == m_fileMode) return;
    m_fileMode = fileMode;
    emit fileModeChanged();
}

void FilePicker::setTitle(const QString &title) {
    if (title == m_title) return;
    m_title = title;
    emit titleChanged();
}

void FilePicker::setAcceptLabel(const QString &acceptLabel) {
    if (acceptLabel == m_acceptLabel) return;
    m_acceptLabel = acceptLabel;
    emit acceptLabelChanged();
}

void FilePicker::setCurrentFolder(const QString &currentFolder) {
    if (currentFolder == m_currentFolder) return;
    m_currentFolder = currentFolder;
    emit currentFolderChanged();
}

void FilePicker::setDefaultSuffix(const QString &defaultSuffix) {
    if (defaultSuffix == m_defaultSuffix) return;
    m_defaultSuffix = defaultSuffix;
    emit defaultSuffixChanged();
}

void FilePicker::setNameFilters(const QStringList &nameFilters) {
    if (nameFilters == m_nameFilters) return;
    m_nameFilters = nameFilters;
    emit nameFiltersChanged();
}

#endif
