BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS AnalysisRecommendations (
  analysisTypeId INTEGER PRIMARY KEY,
  lowText TEXT,                         -- Текст при значении ниже нормы
  normalText TEXT,                      -- Текст при норме
  highText TEXT,                        -- Текст при значении выше нормы
  pregnancyLowText TEXT,                -- Особые рекомендации для беременных
  pregnancyHighText TEXT,
  FOREIGN KEY (analysisTypeId) REFERENCES AnalysisTypes(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS AnalysisResults (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,           -- Связь с профилем пациента
  analysisTypeId INTEGER NOT NULL,      -- Тип анализа
  testDate DATE NOT NULL,               -- Дата сдачи анализа
  value REAL NOT NULL,                  -- Значение результата
  notes TEXT,                           -- Примечания
  laboratory TEXT,                      -- Лаборатория/место сдачи
  isFasting BOOLEAN,                    -- Натощак/не натощак
  FOREIGN KEY (profileId) REFERENCES Profile(id) ON DELETE CASCADE,
  FOREIGN KEY (analysisTypeId) REFERENCES AnalysisTypes(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS AnalysisTypes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,               -- Например: "Кровь", "Моча", "УЗИ"
  name TEXT NOT NULL,                   -- Короткое название (код): "HGB", "GLU"
  displayName TEXT NOT NULL,            -- Отображаемое название: "Гемоглобин"
  unit TEXT NOT NULL,                   -- Единицы измерения: "г/л", "ммоль/л"
  minValue REAL,                        -- Минимальное нормальное значение
  maxValue REAL,                        -- Максимальное нормальное значение
  genderSpecific BOOLEAN DEFAULT FALSE, -- Разные нормы для мужчин/женщин
  pregnancySpecific BOOLEAN DEFAULT TRUE,-- Особые нормы для беременных
  UNIQUE(category, name)
);
CREATE TABLE IF NOT EXISTS ArticleCategories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  icon TEXT
);
CREATE TABLE IF NOT EXISTS ArticleCategoryRelations (
  articleId INTEGER NOT NULL,
  categoryId INTEGER NOT NULL,
  PRIMARY KEY (articleId, categoryId),
  FOREIGN KEY (articleId) REFERENCES Articles(id) ON DELETE CASCADE,
  FOREIGN KEY (categoryId) REFERENCES ArticleCategories(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS ArticleTags (
  articleId INTEGER NOT NULL,
  tagId INTEGER NOT NULL,
  PRIMARY KEY (articleId, tagId),
  FOREIGN KEY (articleId) REFERENCES Articles(id) ON DELETE CASCADE,
  FOREIGN KEY (tagId) REFERENCES Tags(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Articles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  icon TEXT,
  source TEXT,
  isFavorite BOOLEAN DEFAULT FALSE,
  lastShownDate DATE,
  readTimeMinutes INTEGER,
  trimester INTEGER
);
CREATE TABLE IF NOT EXISTS Checklist (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  isDefault BOOLEAN DEFAULT FALSE,
  category TEXT,
  trimester INTEGER
);
CREATE TABLE IF NOT EXISTS CurrentState (
    id INTEGER PRIMARY KEY DEFAULT 1,
    programId INTEGER NOT NULL DEFAULT 1,
    currentDay INTEGER NOT NULL DEFAULT 1,
    FOREIGN KEY (programId) REFERENCES TrainingPrograms(id)
);
CREATE TABLE IF NOT EXISTS DailyPlans (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dayId INTEGER NOT NULL,
    planType TEXT NOT NULL, -- 'appointment', 'medication', etc.
    description TEXT NOT NULL,
    time TIME,
    isCompleted BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (dayId) REFERENCES DailyRecords(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS DailyRecords (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date DATE NOT NULL UNIQUE,
    weight REAL,
    systolicPressure INTEGER,
    diastolicPressure INTEGER,
    waistCircumference REAL,
    mood TEXT,
    notes TEXT
);
CREATE TABLE IF NOT EXISTS DailyTips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tipText TEXT NOT NULL,
  forTrimester INTEGER,
  tags TEXT
);
CREATE TABLE IF NOT EXISTS DaySymptoms (
    dayId INTEGER NOT NULL,
    symptomId INTEGER NOT NULL,
    severity INTEGER CHECK(severity BETWEEN 1 AND 5),
    notes TEXT,
    PRIMARY KEY (dayId, symptomId),
    FOREIGN KEY (dayId) REFERENCES DailyRecords(id) ON DELETE CASCADE,
    FOREIGN KEY (symptomId) REFERENCES Symptoms(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS DietCategories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  icon TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS DietDetails (
  dietId INTEGER PRIMARY KEY,
  indications TEXT NOT NULL,
  dietSchedule TEXT NOT NULL,
  notes TEXT,
  duration TEXT,
  FOREIGN KEY (dietId) REFERENCES Diets(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Diets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  number TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  categoryId INTEGER NOT NULL,
  color TEXT NOT NULL,
  icon TEXT NOT NULL,
  FOREIGN KEY (categoryId) REFERENCES DietCategories(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS ExcludedFoods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dietId INTEGER NOT NULL,
  category TEXT NOT NULL,
  item TEXT NOT NULL,
  FOREIGN KEY (dietId) REFERENCES Diets(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dayId INTEGER NOT NULL,
  exerciseNumber INTEGER NOT NULL,
  sets INTEGER NOT NULL,
  holdTime INTEGER NOT NULL,
  restTime INTEGER NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (dayId) REFERENCES TrainingDays(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS FetalKicks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  sessionDate DATE NOT NULL,
  startTime TIME NOT NULL,
  endTime TIME,
  kickCount INTEGER NOT NULL,
  durationMinutes INTEGER,
  notes TEXT,
  trimester INTEGER,
  isCompleted BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (profileId) REFERENCES Profile(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS LifeCategories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT
);
CREATE TABLE IF NOT EXISTS NotificationSettings (
               id INTEGER PRIMARY KEY CHECK (id = 1), 
               notificationTime TEXT, 
               notificationsEnabled BOOLEAN DEFAULT 1, 
               soundEnabled BOOLEAN DEFAULT 1, 
               vibrationEnabled BOOLEAN DEFAULT 0, 
               vitaminsEnabled BOOLEAN DEFAULT 1, 
               doctorVisitsEnabled BOOLEAN DEFAULT 1, 
               weightMeasurementsEnabled BOOLEAN DEFAULT 0);
CREATE TABLE IF NOT EXISTS PregnancyEvents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  eventDate DATE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  eventType TEXT NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE
);
CREATE TABLE IF NOT EXISTS "PregnancyProgress" (
	"id"	INTEGER,
	"profileId"	INTEGER NOT NULL,
	"startDate"	DATE NOT NULL,
	"currentWeek"	INTEGER NOT NULL,
	"lastUpdated"	DATE NOT NULL,
	"estimatedDueDate"	DATE,
	PRIMARY KEY("id" AUTOINCREMENT),
	FOREIGN KEY("profileId") REFERENCES "Profile"("id") ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS PregnancyWeeks (
  weekNumber INTEGER PRIMARY KEY,
  babySize TEXT NOT NULL,
  babySizeImage TEXT NOT NULL,
  babyLength REAL,
  babyWeight REAL,
  developmentDescription TEXT,
  baby3dModel TEXT DEFAULT "logo");
CREATE TABLE IF NOT EXISTS ProductAliases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productId INTEGER NOT NULL,
  alias TEXT NOT NULL,
  FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS ProductRecommendations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productId INTEGER NOT NULL,
  categoryId INTEGER NOT NULL,
  status TEXT NOT NULL,
  recommendation TEXT,
  scientificBasis TEXT,
  FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE CASCADE,
  FOREIGN KEY (categoryId) REFERENCES LifeCategories(id) ON DELETE CASCADE,
  UNIQUE(productId, categoryId)
);
CREATE TABLE IF NOT EXISTS ProductTypes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  icon TEXT
);
CREATE TABLE IF NOT EXISTS Products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  typeId INTEGER NOT NULL,
  imageSource TEXT NOT NULL,
  description TEXT,
  FOREIGN KEY (typeId) REFERENCES ProductTypes(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Profile (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  firstName TEXT NOT NULL,
  lastName TEXT NOT NULL,
  middleName TEXT,
  dateBirth DATE,
  height INTEGER,
  weight REAL,
  bloodType TEXT,
  profilePhoto TEXT,
  currentProgramId INTEGER,
  initialWeight REAL,
  prePregnancyWeight REAL,
  weightGainGoal REAL);
CREATE TABLE IF NOT EXISTS RecommendedFoods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dietId INTEGER NOT NULL,
  category TEXT NOT NULL,
  item TEXT NOT NULL,
  FOREIGN KEY (dietId) REFERENCES Diets(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Symptoms (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    category TEXT
);
CREATE TABLE IF NOT EXISTS Tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);
CREATE TABLE IF NOT EXISTS TaskNotifications (taskId INTEGER PRIMARY KEY, notificationTime TEXT);
CREATE TABLE IF NOT EXISTS Tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  checklistId INTEGER NOT NULL,
  title TEXT NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE,
  dueDate DATE,
  FOREIGN KEY (checklistId) REFERENCES Checklist(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS TipTags (
  tipId INTEGER NOT NULL,
  tagId INTEGER NOT NULL,
  PRIMARY KEY (tipId, tagId),
  FOREIGN KEY (tipId) REFERENCES Tips(id) ON DELETE CASCADE,
  FOREIGN KEY (tagId) REFERENCES Tags(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS Tips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  icon TEXT,
  isFavorite BOOLEAN DEFAULT FALSE,
  lastShownDate DATE,
  showCount INTEGER DEFAULT 0
);
CREATE TABLE IF NOT EXISTS TrainingDays (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  programId INTEGER NOT NULL,
  dayNumber INTEGER NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (programId) REFERENCES TrainingPrograms(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS TrainingPrograms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  forTrimester INTEGER
);
CREATE TABLE IF NOT EXISTS UserProgress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  lastUpdated DATE DEFAULT CURRENT_DATE,
  currentWeight REAL,
  notes TEXT,
  FOREIGN KEY (profileId) REFERENCES Profile(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS WeightMeasurements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  weight REAL NOT NULL,
  measurementDate DATE NOT NULL,
  trimester INTEGER,
  note TEXT,
  FOREIGN KEY (profileId) REFERENCES Profile(id) ON DELETE CASCADE
);
INSERT INTO "AnalysisResults" ("id","profileId","analysisTypeId","testDate","value","notes","laboratory","isFasting") VALUES (1,1,1,'2023-05-15',115.6,'Первый триместр','Лаборатория №1',1),
 (2,1,1,'2023-06-20',108.2,'Контроль после лечения','Лаборатория №3',1),
 (3,1,2,'2023-06-20',7.8,NULL,'Лаборатория №3',1),
 (4,1,4,'2023-06-01',5.1,'Натощак','Лаборатория №2',1),
 (5,1,5,'2023-05-10',15.0,'Утренняя порция',NULL,0),
 (6,1,7,'2023-06-15',65.3,'Скрининг 2 триместра','УЗИ-центр',1),
 (7,1,8,'2023-06-15',48.2,'Скрининг 2 триместра','УЗИ-центр',1),
 (10,1,4,'2025-05-22',12.0,'','123',1),
 (12,1,4,'2025-06-04',12.0,'','213',1);
INSERT INTO "AnalysisTypes" ("id","category","name","displayName","unit","minValue","maxValue","genderSpecific","pregnancySpecific") VALUES (1,'Кровь','HGB','Гемоглобин','г/л',110.0,150.0,0,1),
 (2,'Кровь','WBC','Лейкоциты','×10⁹/л',4.0,9.0,0,1),
 (3,'Кровь','PLT','Тромбоциты','×10⁹/л',150.0,400.0,0,1),
 (4,'Кровь','GLU','Глюкоза','ммоль/л',3.3,5.5,0,1),
 (5,'Моча','PRO','Белок','мг/дл',0.0,30.0,0,1),
 (6,'Моча','GLU_U','Глюкоза в моче','ммоль/л',NULL,NULL,0,1),
 (7,'УЗИ','BPD','Бипариетальный размер','мм',45.0,85.0,0,1),
 (8,'УЗИ','FL','Длина бедренной кости','мм',32.0,70.0,0,1);
INSERT INTO "ArticleCategories" ("id","name","icon") VALUES (1,'Питание','🍎'),
 (2,'Здоровье','🏥'),
 (3,'Подготовка к родам','👶'),
 (4,'Развитие плода','📅'),
 (5,'Уход за собой','💅'),
 (6,'Психология','🧠'),
 (7,'Отношения в семье','👪'),
 (8,'Финансы','💰');
INSERT INTO "ArticleCategoryRelations" ("articleId","categoryId") VALUES (1,1),
 (1,2),
 (2,3),
 (3,4),
 (4,2),
 (4,5),
 (5,6),
 (6,7),
 (7,8),
 (5,2),
 (6,5),
 (7,1);
INSERT INTO "ArticleTags" ("articleId","tagId") VALUES (1,1),
 (1,2),
 (1,3),
 (2,7),
 (2,8),
 (3,9),
 (3,10),
 (4,11),
 (4,12),
 (5,5),
 (5,9),
 (6,11),
 (6,15),
 (7,1),
 (7,2);
INSERT INTO "Articles" ("id","title","content","icon","source","isFavorite","lastShownDate","readTimeMinutes","trimester") VALUES (1,'Питание во время беременности','Основные принципы питания:\n\n• Увеличьте потребление белка\n• Ешьте больше овощей и фруктов\n• Пейте достаточное количество воды\n• Ограничьте кофеин и исключите алкоголь','🍎','Журнал "Мама и малыш"',0,NULL,5,NULL),
 (2,'Подготовка к родам','Что нужно знать:\n\n1. Пройдите курсы для будущих родителей\n2. Подготовьте сумку в роддом\n3. Изучите техники дыхания\n4. Выберите роддом и врача','👶','Книга "Осознанные роды"',0,NULL,7,NULL),
 (3,'Развитие плода по неделям','Основные этапы развития:\n\n• 1-12 недель: формирование органов\n• 13-27 недель: активный рост\n• 28-40 недель: подготовка к рождению','📅','Сайт baby.ru',0,NULL,10,NULL),
 (4,'Уход за кожей при беременности','Советы по уходу:\n\n1. Используйте увлажняющие кремы\n2. Защищайтесь от солнца\n3. Делайте массаж для профилактики растяжек\n4. Пейте больше воды','💅','Журнал "9 месяцев"',0,NULL,4,NULL),
 (5,'Эмоции во время беременности','Как справляться с перепадами настроения...','🧠','Журнал "9 месяцев"',0,NULL,6,NULL),
 (6,'Подготовка бюджета к рождению ребенка','Основные статьи расходов и как их оптимизировать...','💰','Сайт finam.ru',0,NULL,8,NULL),
 (7,'Отношения с партнером','Как сохранить гармонию в отношениях во время беременности...','👪','Книга "Счастливая семья"',0,NULL,5,NULL);
INSERT INTO "Checklist" ("id","name","isDefault","category","trimester") VALUES (1,'Первый триместр',1,'trimester',1),
 (2,'Второй триместр',1,'trimester',2),
 (3,'Третий триместр',1,'trimester',3),
 (4,'Общие рекомендации',1,'general',NULL);
INSERT INTO "DailyPlans" ("id","dayId","planType","description","time","isCompleted") VALUES (8,2,'medication','123','12:22',0),
 (9,2,'medication','123','12:22',0),
 (11,3,'medication','Узи','11:30',0),
 (12,3,'exercise','природа','12:30',0),
 (13,3,'Прием','Узи','11:30',0),
 (14,4,'Лекарство','Ибупрофен','12:20',0);
INSERT INTO "DailyRecords" ("id","date","weight","systolicPressure","diastolicPressure","waistCircumference","mood","notes") VALUES (1,'2025-04-01',33.0,333,10,32.0,'',NULL),
 (2,'2025-05-01',50.0,120,90,55.0,'безразличная',NULL),
 (3,'2025-05-02',55.0,120,80,21.0,'вдохновленная','213'),
 (4,'2025-05-03',200.0,140,70,200.0,NULL,'Все отлично'),
 (5,'2025-05-31',231.0,213,23,123.0,'вдохновленная','123');
INSERT INTO "DaySymptoms" ("dayId","symptomId","severity","notes") VALUES (2,1,1,''),
 (2,2,1,''),
 (2,4,1,''),
 (3,1,2,'222'),
 (3,2,3,NULL),
 (4,1,1,NULL),
 (5,1,1,NULL);
INSERT INTO "DietCategories" ("id","name","icon") VALUES (1,'Желудочно-кишечные','qrc:/Images/icons/stomach.svg'),
 (2,'Сердечно-сосудистые','qrc:/Images/icons/heart.svg'),
 (3,'Мочеполовая система','qrc:/Images/icons/kidneys.svg'),
 (4,'Обмен веществ','qrc:/Images/icons/metabolism.svg');
INSERT INTO "DietDetails" ("dietId","indications","dietSchedule","notes","duration") VALUES (1,'Язвенная болезнь желудка и 12-перстной кишки, гастриты с повышенной кислотностью','5-6 раз в день небольшими порциями','Пища в отварном и протертом виде','2-3 месяца'),
 (2,'Гепатиты, холециститы, желчнокаменная болезнь','5 раз в день','Исключение жирных и жареных блюд','Длительно'),
 (3,'Сахарный диабет легкой и средней тяжести','5-6 раз в день с равномерным распределением углеводов','Ограничение сахаров и жиров','Постоянно'),
 (4,'Гипертоническая болезнь, ИБС, сердечная недостаточность','4-5 раз в день','Ограничение соли и жидкости','Длительно'),
 (5,'Острый и хронический нефрит, почечная недостаточность','4-5 раз в день','Резкое ограничение соли, умеренное белка','По показаниям');
INSERT INTO "Diets" ("id","number","title","categoryId","color","icon") VALUES (1,'1, 1а, 1б','Язвенная болезнь',1,'#e1bee7','qrc:/Images/icons/stomach.svg'),
 (2,'5, 5а','Заболевания печени и желчных путей',1,'#9c27b0','qrc:/Images/icons/liver.svg'),
 (3,'9','Сахарный диабет',4,'#5e35b1','qrc:/Images/icons/diabetes.svg'),
 (4,'10','Сердечно-сосудистые заболевания',2,'#4a148c','qrc:/Images/icons/heart.svg'),
 (5,'7, 7а, 7б','Нефрит',3,'#7b1fa2','qrc:/Images/icons/kidneys.svg');
INSERT INTO "ExcludedFoods" ("id","dietId","category","item") VALUES (1,1,'Хлеб','Ржаной хлеб'),
 (2,1,'Хлеб','Сдобное тесто'),
 (3,1,'Овощи','Белокочанная капуста'),
 (4,1,'Овощи','Редька, редис'),
 (5,1,'Напитки','Газированные напитки'),
 (6,2,'Мясо','Жирная свинина'),
 (7,2,'Рыба','Соленая рыба'),
 (8,2,'Жиры','Сало, кулинарные жиры'),
 (9,2,'Овощи','Шпинат, щавель'),
 (10,3,'Сладости','Сахар, конфеты'),
 (11,3,'Фрукты','Виноград, изюм'),
 (12,3,'Молочные','Сладкие сырки, сливки'),
 (13,4,'Соль','Поваренная соль (ограничить)'),
 (14,4,'Напитки','Крепкий чай, кофе'),
 (15,4,'Жиры','Тугоплавкие жиры'),
 (16,5,'Соль','Поваренная соль'),
 (17,5,'Бобовые','Горох, фасоль'),
 (18,5,'Мясо','Жирные сорта');
INSERT INTO "Exercises" ("id","dayId","exerciseNumber","sets","holdTime","restTime","isCompleted") VALUES (1,1,1,5,3,5,0),
 (2,1,2,5,3,5,0),
 (3,2,1,6,3,5,0),
 (4,2,2,6,3,5,0),
 (5,3,1,6,4,5,0),
 (6,3,2,6,4,5,0),
 (7,4,1,7,4,5,0),
 (8,4,2,7,4,5,0),
 (9,5,1,7,5,5,0),
 (10,5,2,7,5,5,0),
 (11,6,1,8,5,5,0),
 (12,6,2,8,5,5,0),
 (13,7,1,8,6,5,0),
 (14,7,2,8,6,5,0),
 (15,8,1,5,5,10,0),
 (16,8,2,5,5,10,0),
 (17,9,1,6,5,10,0),
 (18,9,2,6,5,10,0),
 (19,10,1,6,6,10,0),
 (20,10,2,6,6,10,0),
 (21,11,1,7,6,10,0),
 (22,11,2,7,6,10,0),
 (23,12,1,7,7,10,0),
 (24,12,2,7,7,10,0),
 (25,13,1,8,7,10,0),
 (26,13,2,8,7,10,0),
 (27,14,1,8,8,10,0),
 (28,14,2,8,8,10,0),
 (29,15,1,8,1,3,0),
 (30,15,2,8,1,3,0),
 (31,16,1,10,1,3,0),
 (32,16,2,10,1,3,0),
 (33,17,1,10,1,3,0),
 (34,17,2,10,1,3,0),
 (35,18,1,12,1,3,0),
 (36,18,2,12,1,3,0),
 (37,19,1,12,1,3,0),
 (38,19,2,12,1,3,0),
 (39,20,1,15,1,3,0),
 (40,20,2,15,1,3,0),
 (41,21,1,15,1,3,0),
 (42,21,2,15,1,3,0),
 (43,22,1,5,5,10,0),
 (44,22,2,5,5,10,0),
 (45,23,1,5,6,10,0),
 (46,23,2,5,6,10,0),
 (47,24,1,6,6,10,0),
 (48,24,2,6,6,10,0),
 (49,25,1,6,7,10,0),
 (50,25,2,6,7,10,0),
 (51,26,1,7,7,10,0),
 (52,26,2,7,7,10,0),
 (53,27,1,7,8,10,0),
 (54,27,2,7,8,10,0),
 (55,28,1,8,8,10,0),
 (56,28,2,8,8,10,0),
 (57,29,1,4,5,8,0),
 (58,29,2,4,5,8,0),
 (59,30,1,4,6,8,0),
 (60,30,2,4,6,8,0),
 (61,31,1,5,6,8,0),
 (62,31,2,5,6,8,0),
 (63,32,1,5,7,8,0),
 (64,32,2,5,7,8,0),
 (65,33,1,6,7,8,0),
 (66,33,2,6,7,8,0),
 (67,34,1,6,8,8,0),
 (68,34,2,6,8,8,0),
 (69,35,1,6,8,10,0),
 (70,35,2,6,8,10,0),
 (71,36,1,5,3,3,0),
 (72,36,2,5,1,3,0),
 (73,37,1,6,3,3,0),
 (74,37,2,6,1,3,0),
 (75,38,1,6,4,3,0),
 (76,38,2,6,1,3,0),
 (77,39,1,7,4,3,0),
 (78,39,2,7,1,3,0),
 (79,40,1,7,5,3,0),
 (80,40,2,7,1,3,0),
 (81,41,1,8,5,3,0),
 (82,41,2,8,1,3,0),
 (83,42,1,10,5,3,0),
 (84,42,2,10,1,3,0);
INSERT INTO "FetalKicks" ("id","profileId","sessionDate","startTime","endTime","kickCount","durationMinutes","notes","trimester","isCompleted") VALUES (4,1,'2023-06-05','09:45:00',NULL,10,30,'',NULL,1),
 (7,1,'2025-05-21','01:56:57.288',NULL,3,NULL,'',NULL,1);
INSERT INTO "LifeCategories" ("id","name","description") VALUES (1,'Беременность','Рекомендации для периода беременности'),
 (2,'Грудное вскармливание','Рекомендации для периода кормления грудью'),
 (3,'После родов','Рекомендации для периода после родов'),
 (4,'Младенцы','Рекомендации для младенцев');
INSERT INTO "NotificationSettings" ("id","notificationTime","notificationsEnabled","soundEnabled","vibrationEnabled","vitaminsEnabled","doctorVisitsEnabled","weightMeasurementsEnabled") VALUES (1,'01:50',1,1,0,1,1,0);
INSERT INTO "PregnancyProgress" ("id","profileId","startDate","currentWeek","lastUpdated","estimatedDueDate") VALUES (4,1,'2025-05-07',4,'2025-06-04','2026-02-11');
INSERT INTO "PregnancyWeeks" ("weekNumber","babySize","babySizeImage","babyLength","babyWeight","developmentDescription","baby3dModel") VALUES (1,'Мак','poppy',0.1,0.0,'Оплодотворение яйцеклетки и начало деления клеток','logo'),
 (4,'Горошина','peas',0.5,0.5,'Формирование нервной трубки и сердца','logo'),
 (8,'Малина','raspberry',1.6,1.0,'Начинают формироваться черты лица','logo'),
 (12,'Лимон','lemon',6.0,14.0,'Сформированы все основные органы','logo'),
 (16,'Авокадо','avocado',11.6,100.0,'Малыш начинает двигаться','logo'),
 (20,'Банан','banana',16.0,300.0,'Плод начинает слышать','logo'),
 (24,'Кукуруза','corn',30.0,600.0,'Развиваются легкие','logo'),
 (28,'Баклажан','eggplant',37.6,1000.0,'Открывает и закрывает глаза','logo'),
 (32,'Тыква','pumpkin',42.4,1700.0,'Быстро набирает вес','logo'),
 (36,'Дыня','melon',47.4,2600.0,'Занимает окончательное положение','logo'),
 (40,'Тыква','pumpkin',51.0,3400.0,'Готов к рождению','logo');
INSERT INTO "ProductRecommendations" ("id","productId","categoryId","status","recommendation","scientificBasis") VALUES (1,1,1,'Умеренно','Употреблять 1-2 яблока в день','Исследования показывают пользу для пищеварения'),
 (2,1,2,'Умеренно','Употреблять с осторожностью, наблюдая за реакцией ребенка','Могут вызывать колики у младенцев'),
 (3,1,3,'Осторожно','Начинать с печеных яблок','Легче усваиваются после термической обработки'),
 (4,1,4,'Нельзя','Не давать целые яблоки до 3 лет','Риск подавиться'),
 (5,2,1,'Умеренно','1-2 стакана в день','Источник кальция и витамина D'),
 (6,2,2,'Осторожно','Наблюдать за реакцией ребенка','Может вызывать аллергию'),
 (7,2,3,'Умеренно','Предпочитать кисломолочные продукты','Лучше усваиваются'),
 (8,2,4,'Нельзя','Не давать коровье молоко до года','Может вызывать анемию'),
 (9,3,1,'Рекомендуется','Употреблять в любом виде','Богата витамином А'),
 (10,3,2,'Умеренно','Начинать с небольших количеств','Может изменять вкус молока'),
 (11,3,3,'Рекомендуется','Полезно для восстановления','Содержит антиоксиданты'),
 (12,3,4,'Осторожно','Вводить с 6 месяцев в виде пюре','Рекомендации ВОЗ'),
 (13,4,1,'Рекомендуется','3-4 раза в неделю','Источник железа и белка'),
 (14,4,2,'Рекомендуется','Хорошо проваривать','Легче усваивается'),
 (15,4,3,'Рекомендуется','Для восстановления после родов','Помогает при анемии'),
 (16,4,4,'Осторожно','Вводить с 8 месяцев в виде пюре','Рекомендации педиатров'),
 (17,5,1,'Рекомендуется','2-3 раза в неделю','Богат омега-3 для развития мозга плода'),
 (18,5,2,'Рекомендуется','Только термически обработанный','Безопасность для ребенка'),
 (19,5,3,'Рекомендуется','Для восстановления организма','Полезные жиры'),
 (20,5,4,'Осторожно','Вводить после года','Возможность аллергии');
INSERT INTO "ProductTypes" ("id","name","icon") VALUES (1,'Фрукты','qrc:/Images/icons/fruits.svg'),
 (2,'Овощи','qrc:/Images/icons/vegetables.svg'),
 (3,'Молочные продукты','qrc:/Images/icons/milk.svg'),
 (4,'Мясо','qrc:/Images/icons/meat.svg'),
 (5,'Рыба','qrc:/Images/icons/fish.svg');
INSERT INTO "Products" ("id","name","typeId","imageSource","description") VALUES (1,'Яблоки',1,'qrc:/Images/food/apple.svg','Свежие яблоки богаты клетчаткой и витаминами'),
 (2,'Молоко',3,'qrc:/Images/food/milk.svg','Коровье молоко содержит кальций и белки'),
 (3,'Морковь',2,'qrc:/Images/food/carrot.svg','Морковь богата витамином А и бета-каротином'),
 (4,'Говядина',4,'qrc:/Images/food/beef.svg','Источник железа и белка'),
 (5,'Лосось',5,'qrc:/Images/food/salmon.svg','Богат омега-3 жирными кислотами');
INSERT INTO "Profile" ("id","firstName","lastName","middleName","dateBirth","height","weight","bloodType","profilePhoto","currentProgramId","initialWeight","prePregnancyWeight","weightGainGoal") VALUES (1,'Воробьева','Анастасия','Владимировна',NULL,180,80.0,'1','file:///C:/Users/kosty/Downloads/Telegram Desktop/DSCN0551.JPG',NULL,0.0,0.0,0.0);
INSERT INTO "RecommendedFoods" ("id","dietId","category","item") VALUES (1,1,'Хлеб','Пшеничный вчерашней выпечки'),
 (2,1,'Хлеб','Сухари белые'),
 (3,1,'Супы','Молочные с протертыми крупами'),
 (4,1,'Супы','Овощные протертые'),
 (5,1,'Мясо','Нежирная говядина, курица, кролик (отварные)'),
 (6,2,'Молочные','Творог нежирный'),
 (7,2,'Крупы','Гречневая, овсяная'),
 (8,2,'Овощи','Морковь, свекла (отварные)'),
 (9,2,'Фрукты','Сладкие яблоки, бананы'),
 (10,3,'Хлеб','Ржаной, белково-отрубяной'),
 (11,3,'Овощи','Капуста, кабачки, огурцы'),
 (12,3,'Крупы','Гречневая, ячневая'),
 (13,3,'Мясо','Нежирные сорта'),
 (14,4,'Овощи','Картофель, морковь, свекла'),
 (15,4,'Фрукты','Курага, изюм (источники калия)'),
 (16,4,'Крупы','Все виды круп'),
 (17,4,'Молочные','Кефир, творог'),
 (18,5,'Овощи','Картофель, тыква'),
 (19,5,'Фрукты','Арбуз, дыня'),
 (20,5,'Крупы','Рис, саго'),
 (21,5,'Хлеб','Безбелковый');
INSERT INTO "Symptoms" ("id","name","category") VALUES (1,'всё в порядке','general'),
 (2,'акне','skin'),
 (3,'головная боль','pain'),
 (4,'боль в пояснице','pain'),
 (5,'боли в теле','pain'),
 (6,'спазмы внизу живота','pain'),
 (7,'усталость','general'),
 (8,'вдохновленная','mood'),
 (9,'безразличная','mood'),
 (10,'радостная','mood'),
 (11,'грустная','mood'),
 (12,'злая','mood'),
 (13,'возбужденная','mood'),
 (14,'в панике','mood');
INSERT INTO "Tags" ("id","name") VALUES (1,'витамины'),
 (2,'здоровье'),
 (3,'активность'),
 (4,'спорт'),
 (5,'токсикоз'),
 (6,'питание'),
 (7,'анализы'),
 (8,'УЗИ'),
 (9,'гигиена'),
 (10,'диета'),
 (11,'рецепты'),
 (12,'курсы'),
 (13,'роддом'),
 (14,'триместры'),
 (15,'календарь'),
 (16,'красота'),
 (17,'фитнес');
INSERT INTO "Tasks" ("id","checklistId","title","isCompleted","dueDate") VALUES (1,1,'Встать на учет в ЖК',1,NULL),
 (2,1,'Сдать общий анализ крови',1,NULL),
 (3,1,'Сдать анализ мочи',1,NULL),
 (4,1,'Первый скрининг (УЗИ + биохимия)',1,NULL),
 (5,2,'Второй скрининг (УЗИ)',0,NULL),
 (6,2,'Анализ на глюкозу',0,NULL),
 (7,2,'Посещение стоматолога',0,NULL),
 (8,2,'Курсы для беременных',0,NULL),
 (9,3,'Третий скрининг (УЗИ)',0,NULL),
 (10,3,'КТГ плода',0,NULL),
 (11,3,'Собрать сумку в роддом',0,NULL),
 (12,3,'Выбрать роддом',0,NULL),
 (13,4,'Принимать витамины',0,NULL),
 (14,4,'Следить за питанием',0,NULL),
 (15,4,'Выполнять упражнения',0,NULL),
 (16,4,'Контролировать вес',0,NULL);
INSERT INTO "TipTags" ("tipId","tagId") VALUES (1,1),
 (1,2),
 (2,3),
 (2,4),
 (3,5),
 (3,6),
 (4,7),
 (4,8),
 (5,6),
 (5,9),
 (6,14),
 (6,15),
 (7,6),
 (7,14),
 (8,9),
 (8,16);
INSERT INTO "Tips" ("id","question","answer","icon","isFavorite","lastShownDate","showCount") VALUES (1,'Какие витамины нужны?','Фолиевая кислота (400 мкг/день) в первом триместре. По назначению врача: йод, железо, витамин D.','💊',0,'2025-05-20',7),
 (2,'Можно ли заниматься спортом?','Да! Рекомендуется:\n• Йога для беременных\n• Плавание\n• Пешие прогулки\nИзбегайте экстремальных видов спорта.','🏃‍♀️',0,'2025-05-25',16),
 (3,'Как справляться с токсикозом?','1. Дробное питание\n2. Имбирный чай\n3. Избегайте резких запахов\nПри сильных симптомах - к врачу.','🤢',0,'2025-05-20',10),
 (4,'Когда делать первое УЗИ?','Первое УЗИ рекомендуется на 10-14 неделе беременности. Оно помогает оценить развитие плода и выявить возможные патологии.','👶',0,'2025-05-20',10),
 (5,'Как правильно питаться?','Основные правила:\n1. Частые приемы пищи небольшими порциями\n2. Больше овощей и фруктов\n3. Достаточное количество белка\n4. Ограничить кофеин','🍎',0,'2025-05-25',14),
 (6,'Когда чувствуются шевеления?','Первые шевеления обычно ощущаются между 18 и 22 неделями у первородящих и между 16 и 18 неделями у повторнородящих.','👶',0,NULL,0),
 (7,'Какая прибавка веса нормальна?','Средняя прибавка за беременность 10-12 кг:\n1 триместр: 1-2 кг\n2 триместр: 4-5 кг\n3 триместр: 5-6 кг','⚖️',0,NULL,0),
 (8,'Как спать при беременности?','Лучше на боку, особенно на левом. Используйте подушки для поддержки живота и спины.','🛌',0,NULL,0);
INSERT INTO "TrainingDays" ("id","programId","dayNumber","isCompleted") VALUES (1,1,1,0),
 (2,1,2,0),
 (3,1,3,0),
 (4,1,4,0),
 (5,1,5,0),
 (6,1,6,0),
 (7,1,7,0),
 (8,2,1,0),
 (9,2,2,0),
 (10,2,3,0),
 (11,2,4,0),
 (12,2,5,0),
 (13,2,6,0),
 (14,2,7,0),
 (15,3,1,0),
 (16,3,2,0),
 (17,3,3,0),
 (18,3,4,0),
 (19,3,5,0),
 (20,3,6,0),
 (21,3,7,0),
 (22,4,1,0),
 (23,4,2,0),
 (24,4,3,0),
 (25,4,4,0),
 (26,4,5,0),
 (27,4,6,0),
 (28,4,7,0),
 (29,5,1,0),
 (30,5,2,0),
 (31,5,3,0),
 (32,5,4,0),
 (33,5,5,0),
 (34,5,6,0),
 (35,5,7,0),
 (36,6,1,0),
 (37,6,2,0),
 (38,6,3,0),
 (39,6,4,0),
 (40,6,5,0),
 (41,6,6,0),
 (42,6,7,0);
INSERT INTO "TrainingPrograms" ("id","name","description","forTrimester") VALUES (1,'Базовые упражнения Кегеля','Программа для начинающих, подходит для первого триместра',1),
 (2,'Базовые медленные сокращения','Основная программа для укрепления мышц тазового дна',0),
 (3,'Быстрые сокращения','Тренировка для женщин со стрессовым недержанием мочи',0),
 (4,'Усложненные упражнения','Программа для продвинутых с постепенным увеличением интенсивности',0),
 (5,'Лифтовые сокращения','Многоуровневая тренировка с поэтапным сокращением',0),
 (6,'Чередование','Комбинированная программа с чередованием быстрых и медленных сокращений',0);
INSERT INTO "WeightMeasurements" ("id","profileId","weight","measurementDate","trimester","note") VALUES (10,1,68.0,'2025-05-21',NULL,''),
 (16,1,0.0,'2025-03-02',NULL,NULL),
 (17,1,50.0,'2025-04-14',NULL,NULL),
 (18,1,33.0,'2025-04-01',NULL,NULL),
 (19,1,20.0,'2025-04-02',NULL,NULL);
CREATE INDEX idx_analysis_results_type ON AnalysisResults(analysisTypeId);
CREATE INDEX idx_articlecategories_relations ON ArticleCategoryRelations(articleId, categoryId);
CREATE INDEX idx_articletags_article ON ArticleTags(articleId);
CREATE INDEX idx_articletags_tag ON ArticleTags(tagId);
CREATE INDEX idx_diets_category ON Diets(categoryId);
CREATE INDEX idx_excluded_foods_diet ON ExcludedFoods(dietId);
CREATE INDEX idx_fetal_kicks_profile ON FetalKicks(profileId);
CREATE INDEX idx_pregnancy_progress_profile ON PregnancyProgress(profileId);
CREATE INDEX idx_product_aliases_product ON ProductAliases(productId);
CREATE INDEX idx_product_recommendations_category ON ProductRecommendations(categoryId);
CREATE INDEX idx_product_recommendations_product ON ProductRecommendations(productId);
CREATE INDEX idx_products_type ON Products(typeId);
CREATE INDEX idx_recommended_foods_diet ON RecommendedFoods(dietId);
CREATE INDEX idx_tasks_checklist ON Tasks(checklistId);
CREATE INDEX idx_tiptags_tag ON TipTags(tagId);
CREATE INDEX idx_tiptags_tip ON TipTags(tipId);
CREATE INDEX idx_user_progress_profile ON UserProgress(profileId);
CREATE INDEX idx_weight_measurements_profile ON WeightMeasurements(profileId);
COMMIT;
