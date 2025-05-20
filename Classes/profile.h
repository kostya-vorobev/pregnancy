// profile.h
#ifndef PROFILE_H
#define PROFILE_H

#include <QObject>
#include <QDate>


class Profile : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QString firstName READ firstName WRITE setFirstName NOTIFY firstNameChanged)
    Q_PROPERTY(QString lastName READ lastName WRITE setLastName NOTIFY lastNameChanged)
    Q_PROPERTY(QString middleName READ middleName WRITE setMiddleName NOTIFY middleNameChanged)
    Q_PROPERTY(QDate dateBirth READ dateBirth WRITE setDateBirth NOTIFY dateBirthChanged)
    Q_PROPERTY(int height READ height WRITE setHeight NOTIFY heightChanged)
    Q_PROPERTY(double weight READ weight WRITE setWeight NOTIFY weightChanged)
    Q_PROPERTY(QString bloodType READ bloodType WRITE setBloodType NOTIFY bloodTypeChanged)
    Q_PROPERTY(QString profilePhoto READ profilePhoto WRITE setProfilePhoto NOTIFY profilePhotoChanged)

public:

    enum Status { Null, Loading, Ready, Error };
    Q_ENUM(Status)
    Q_PROPERTY(Status status READ status NOTIFY statusChanged)

    explicit Profile(QObject *parent = nullptr);
    Profile(int id, const QString &firstName, const QString &lastName,
            const QString &middleName, const QDate &dateBirth,
            int height, double weight, const QString &bloodType,
            const QString &profilePhoto, QObject *parent = nullptr);

    // Getters
    int id() const;
    QString firstName() const;
    QString lastName() const;
    QString middleName() const;
    QDate dateBirth() const;
    int height() const;
    double weight() const;
    QString bloodType() const;
    QString profilePhoto() const;
    Status status() const { return m_status; }

    // Setters
    void setFirstName(const QString &firstName);
    void setLastName(const QString &lastName);
    void setMiddleName(const QString &middleName);
    void setDateBirth(const QDate &dateBirth);
    void setHeight(int height);
    void setWeight(double weight);
    void setBloodType(const QString &bloodType);
    void setProfilePhoto(const QString &profilePhoto);
    void setId(int id);

    Q_INVOKABLE bool loadData();
    Q_INVOKABLE bool save();

    // Database operations
    static Profile* getProfile(int id);
    static QList<Profile*> getAllProfiles();
    //bool save();
    bool remove();


signals:
    void idChanged();
    void firstNameChanged();
    void lastNameChanged();
    void middleNameChanged();
    void dateBirthChanged();
    void heightChanged();
    void weightChanged();
    void bloodTypeChanged();
    void profilePhotoChanged();
    void dataLoaded();
    void dataSaved();
    void statusChanged();

private:
    int m_id;
    QString m_firstName;
    QString m_lastName;
    QString m_middleName;
    QDate m_dateBirth;
    int m_height;
    double m_weight;
    QString m_bloodType;
    QString m_profilePhoto;
    Status m_status = Null;
};

#endif // PROFILE_H
