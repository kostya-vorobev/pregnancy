// profile.cpp
#include "profile.h"
#include "databasemanager.h"
#include <QSqlQuery>
#include <QSqlError>
#include <QDebug>

Profile::Profile(QObject *parent) : QObject(parent),
    m_id(-1), m_height(0), m_weight(0.0)
{
}

Profile::Profile(int id, const QString &firstName, const QString &lastName,
                 const QString &middleName, const QDate &dateBirth,
                 int height, double weight, const QString &bloodType,
                 const QString &profilePhoto, QObject *parent)
    : QObject(parent), m_id(id), m_firstName(firstName), m_lastName(lastName),
    m_middleName(middleName), m_dateBirth(dateBirth), m_height(height),
    m_weight(weight), m_bloodType(bloodType), m_profilePhoto(profilePhoto)
{
}

// Реализация геттеров
int Profile::id() const { return m_id; }
QString Profile::firstName() const { return m_firstName; }
QString Profile::lastName() const { return m_lastName; }
QString Profile::middleName() const { return m_middleName; }
QDate Profile::dateBirth() const { return m_dateBirth; }
int Profile::height() const { return m_height; }
double Profile::weight() const { return m_weight; }
QString Profile::bloodType() const { return m_bloodType; }
QString Profile::profilePhoto() const { return m_profilePhoto; }

// Реализация сеттеров
void Profile::setId(int id) {
    if (m_id != id) {
        m_id = id;
        emit idChanged();
    }
}

void Profile::setFirstName(const QString &firstName) {
    if (m_firstName != firstName) {
        m_firstName = firstName;
        emit firstNameChanged();
    }
}

void Profile::setLastName(const QString &lastName) {
    if (m_lastName != lastName) {
        m_lastName = lastName;
        emit lastNameChanged();
    }
}

void Profile::setMiddleName(const QString &middleName) {
    if (m_middleName != middleName) {
        m_middleName = middleName;
        emit middleNameChanged();
    }
}

void Profile::setDateBirth(const QDate &dateBirth) {
    if (m_dateBirth != dateBirth) {
        m_dateBirth = dateBirth;
        emit dateBirthChanged();
    }
}

void Profile::setHeight(int height) {
    if (m_height != height) {
        m_height = height;
        emit heightChanged();
    }
}

void Profile::setWeight(double weight) {
    if (!qFuzzyCompare(m_weight, weight)) {
        m_weight = weight;
        emit weightChanged();
    }
}

void Profile::setBloodType(const QString &bloodType) {
    if (m_bloodType != bloodType) {
        m_bloodType = bloodType;
        emit bloodTypeChanged();
    }
}

void Profile::setProfilePhoto(const QString &profilePhoto) {
    if (m_profilePhoto != profilePhoto) {
        m_profilePhoto = profilePhoto;
        emit profilePhotoChanged();
    }
}



// Остальные сеттеры аналогично...

// Database operations
Profile* Profile::getProfile(int id)
{
    QSqlQuery query;
    query.prepare("SELECT * FROM Profile WHERE id = :id");
    query.bindValue(":id", id);

    if (!query.exec()) {
        qWarning() << "Failed to get profile:" << query.lastError().text();
        return nullptr;
    }

    if (query.next()) {
        return new Profile(
            query.value("id").toInt(),
            query.value("firstName").toString(),
            query.value("lastName").toString(),
            query.value("middleName").toString(),
            query.value("dateBirth").toDate(),
            query.value("height").toInt(),
            query.value("weight").toDouble(),
            query.value("bloodType").toString(),
            query.value("profilePhoto").toString()
            );
    }

    return nullptr;
}

QList<Profile*> Profile::getAllProfiles()
{
    QList<Profile*> profiles;
    QSqlQuery query("SELECT * FROM Profile");

    while (query.next()) {
        profiles.append(new Profile(
            query.value("id").toInt(),
            query.value("firstName").toString(),
            query.value("lastName").toString(),
            query.value("middleName").toString(),
            query.value("dateBirth").toDate(),
            query.value("height").toInt(),
            query.value("weight").toDouble(),
            query.value("bloodType").toString(),
            query.value("profilePhoto").toString()
            ));
    }

    return profiles;
}

bool Profile::loadData() {
    if (m_id <= 0) return false;

    m_status = Loading;
    emit statusChanged();

    QSqlQuery query;
    query.prepare("SELECT * FROM Profile WHERE id = :id");
    query.bindValue(":id", m_id);

    if (!query.exec() || !query.next()) {
        m_status = Error;
        emit statusChanged();
        return false;
    }

    m_firstName = query.value("firstName").toString();
    m_lastName = query.value("lastName").toString();
    m_middleName = query.value("middleName").toString();
    m_dateBirth = query.value("dateBirth").toDate();
    m_height = query.value("height").toInt();
    m_weight = query.value("weight").toDouble();
    m_bloodType = query.value("bloodType").toString();
    m_profilePhoto = query.value("profilePhoto").toString();

    m_status = Ready;
    emit statusChanged();
    emit dataLoaded();
    return true;
}

bool Profile::save() {
    QSqlQuery query;

    if (m_id <= 0) {
        // Новая запись
        query.prepare("INSERT INTO Profile (firstName, lastName, middleName, dateBirth, height, weight, bloodType, profilePhoto) "
                      "VALUES (:firstName, :lastName, :middleName, :dateBirth, :height, :weight, :bloodType, :profilePhoto)");
    } else {
        // Обновление
        query.prepare("UPDATE Profile SET "
                      "firstName = :firstName, "
                      "lastName = :lastName, "
                      "middleName = :middleName, "
                      "dateBirth = :dateBirth, "
                      "height = :height, "
                      "weight = :weight, "
                      "bloodType = :bloodType, "
                      "profilePhoto = :profilePhoto "
                      "WHERE id = :id");
        query.bindValue(":id", m_id);
    }

    // Привязка значений
    query.bindValue(":firstName", m_firstName);
    query.bindValue(":lastName", m_lastName);
    query.bindValue(":middleName", m_middleName);
    query.bindValue(":dateBirth", m_dateBirth);
    query.bindValue(":height", m_height);
    query.bindValue(":weight", m_weight);
    query.bindValue(":bloodType", m_bloodType);
    query.bindValue(":profilePhoto", m_profilePhoto);

    if (!query.exec()) {
        qWarning() << "Failed to save profile:" << query.lastError().text();
        return false;
    }

    if (m_id <= 0) {
        m_id = query.lastInsertId().toInt();
    }

    emit dataSaved();
    return true;
}

bool Profile::copyProfilePhoto(const QString &sourcePath) {
    if (sourcePath.isEmpty()) return false;

    // Определяем путь для сохранения фото
    QString appDataPath = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    QDir appDataDir(appDataPath);
    if (!appDataDir.exists()) {
        appDataDir.mkpath(".");
    }

    QString destFileName = QString("profile_%1.%2").arg(m_id).arg(QFileInfo(sourcePath).suffix());
    QString destPath = appDataDir.filePath(destFileName);

    // Удаляем старое фото, если оно есть
    if (!m_profilePhoto.isEmpty() && m_profilePhoto != destPath) {
        QFile::remove(m_profilePhoto);
    }

    // Копируем новое фото
    if (QFile::copy(sourcePath, destPath)) {
        m_profilePhoto = destPath;
        emit profilePhotoChanged();
        return true;
    }

    return false;
}

bool Profile::remove()
{
    if (m_id == -1) {
        return false;
    }

    QSqlQuery query;
    query.prepare("DELETE FROM Profile WHERE id = :id");
    query.bindValue(":id", m_id);

    if (!query.exec()) {
        qWarning() << "Failed to remove profile:" << query.lastError().text();
        return false;
    }

    return true;
}
