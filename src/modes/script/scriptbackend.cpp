#include "scriptbackend.h"
#include "cpphighlighter.h"
#include "pythonhighlighter.h"
#include "appbackend.h"

static const QString location = AppBackend::tempLocation() + "script/";
#ifdef Q_OS_WINDOWS
    static const char* compiler = "D:/Programs/Qt/6.7.2/mingw_64/bin/g++.exe";
    static const QString exec = location + "execute.exe";
    static const char*  interpreter = "script/Python/python.exe";
#elif defined(Q_OS_LINUX)
    static const char* compiler = "g++";
    static const char*  interpreter = "python3";
#endif

ScriptBackend::ScriptBackend(QObject *parent) : QObject (parent),
    m_language(Language(-1)),
    m_syntaxHighlighter(nullptr),
    m_process(new QProcess(this))
{
    // Терминал
    connect(m_process, &QProcess::errorOccurred, this, [this](QProcess::ProcessError error) {
        //stop();
        qDebug() << error;
    });
    connect(m_process, &QProcess::started, this, []
    {
        //qDebug() << "Started";
    });
    connect(m_process, &QProcess::finished, this, [this](int exitCode, QProcess::ExitStatus exitStatus)
    {
        qDebug() << exitCode << exitStatus;
        if (exitCode == 0 && exitStatus == QProcess::NormalExit) {
            if (m_process->program() == compiler) {
                m_process->start(exec);
            } else if (m_process->program() == exec || m_process->program() == interpreter) {
                //stop();
            }
        }
    });
    connect(m_process, &QProcess::readyReadStandardOutput, this, [this]
    {
        qDebug() << "output:" << m_process->readAllStandardOutput();
        /*if (m_process->program() == exec || m_process->program() == interpreter)
        {
            //m_currentCommand = m_process->readAll().trimmed().split(' ');
            //if (!m_currentCommand.isEmpty()) scriptHandler(m_currentCommand);
        }*/
    });
    connect(m_process, &QProcess::readyReadStandardError, this, [this]
    {
        qDebug() << "error:" << m_process->readAllStandardError();
    });
}

void ScriptBackend::setLanguage(Language language)
{
    if (language == m_language || !m_textDocument) return;
    QSyntaxHighlighter *newHighlighter = nullptr;
    switch (language) {
    case Cpp: newHighlighter = new CppHighlighter(m_textDocument->textDocument()); break;
    case Python: newHighlighter = new PythonHighlighter(m_textDocument->textDocument()); break;
    default: return; break;
    }
    m_language = language;
    if (m_syntaxHighlighter) m_syntaxHighlighter->deleteLater();
    m_syntaxHighlighter = newHighlighter;
    emit languageChanged();
}

void ScriptBackend::setTextDocument(QQuickTextDocument *textDocument)
{
    if (textDocument == m_textDocument) return;
    m_textDocument = textDocument;
    emit textDocumentChanged();
}

void ScriptBackend::start(const QString &code)
{
    if (m_process->state() != QProcess::Running)
    {
        QFile hLib(":/script/hobots.h"), hLibCopy(location + "hobots.h"), script;
        switch (m_language) {
        case Cpp:
            hLib.setFileName(":/script/hobots.h");
            hLibCopy.setFileName(location + "hobots.h");
            script.setFileName(location + "main.cpp");
            m_process->setProgram("g++");
            m_process->setArguments({ location + "main.cpp", "-o", exec });
            break;
        case Python:
            hLib.setFileName(":/script/hobots.py");
            hLibCopy.setFileName(location + "hobots.py");
            script.setFileName(location + "main.py");
            m_process->setProgram("python");
            m_process->setArguments({ location + "main.py" });
            break;
        default:
            qDebug() << "Неизвестный язык";
            return;
        }
        // создание папки для хранения временных файлов
        if (!QDir(location).exists()) QDir().mkpath(location);

        // копирование заголовочного файла
        /*QFile hdLib(m_location + "hobotd.h");
        if (hdLib.exists()) qDebug() << hdLib.remove();
        if (!QFile::copy(":/Hobot-D/script/hobotd.h", m_location + "hobotd.h"))
        {
            ui->start->setChecked(false);
            return;
        }
        hdLib.setPermissions(QFileDevice::WriteUser);*/

        if (!hLib.open(QIODevice::ReadOnly) || !hLibCopy.open(QIODevice::WriteOnly))
        {
            //ui->toolBar->setStarted(false);
            return;
        }
        hLibCopy.write(hLib.readAll());
        hLib.close();
        hLibCopy.close();

        // создание файла скрипта
        if (!script.open(QIODevice::WriteOnly | QIODevice::Text))
        {
            //ui->toolBar->setStarted(false);
            return;
        }
        script.write(code.toUtf8());
        script.close();

        m_process->start();
    }
    else // resume
    {
        //scriptHandler(m_currentCommand);
    }

    //m_process->start("python", {"--version"});
}
