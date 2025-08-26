#ifndef SCRIPTBACKEND_H
#define SCRIPTBACKEND_H

#include <QObject>
#include <QQmlEngine>
#include <QQuickTextDocument>
#include <QSyntaxHighlighter>
#include <QProcess>

class ScriptBackend : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(Language language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QQuickTextDocument *textDocument READ textDocument WRITE setTextDocument NOTIFY textDocumentChanged)
public:
    enum Language { Cpp, Python };
    Q_ENUM(Language)
    ScriptBackend(QObject *parent = nullptr);
    inline Language language() const { return m_language; };
    inline QQuickTextDocument *textDocument() const { return m_textDocument; };
    void setLanguage(Language language);
    void setTextDocument(QQuickTextDocument *textDocument);
    Q_INVOKABLE void start(const QString &code);

private:
    Language m_language;
    QSyntaxHighlighter *m_syntaxHighlighter;
    QQuickTextDocument *m_textDocument;
    QProcess *m_process;

signals:
    void languageChanged();
    void textDocumentChanged();
};

#endif // SCRIPTBACKEND_H
