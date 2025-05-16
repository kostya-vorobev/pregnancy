/*
Комплексная база данных для приложения беременности
Оптимизирована для SQLite 3.7
Версия: 1.0
Дата создания: 16.05.2025
*/

-- Основная таблица профиля пользователя
CREATE TABLE Profile (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  firstName TEXT NOT NULL,
  lastName TEXT NOT NULL,
  dateBirth DATE NOT NULL,
  gestationalAge INTEGER NOT NULL,
  estimatedDate DATE NOT NULL,
  height INTEGER,
  weight REAL,
  bloodType TEXT,
  profilePhoto TEXT,
  currentProgramId INTEGER,
  initialWeight REAL,
  prePregnancyWeight REAL,
  weightGainGoal REAL,
  midleName TEXT,
);

-- Таблица чеклистов
CREATE TABLE Checklist (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  isDefault BOOLEAN DEFAULT FALSE,
  category TEXT,
  trimester INTEGER
);

-- Таблица задач чеклистов
CREATE TABLE Tasks (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  checklistId INTEGER NOT NULL,
  title TEXT NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE,
  dueDate DATE,
  FOREIGN KEY (checklistId) REFERENCES Checklist(id) ON DELETE CASCADE
);

-- Таблица программ тренировок
CREATE TABLE TrainingPrograms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  forTrimester INTEGER
);

-- Таблица дней тренировок
CREATE TABLE TrainingDays (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  programId INTEGER NOT NULL,
  dayNumber INTEGER NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (programId) REFERENCES TrainingPrograms(id) ON DELETE CASCADE
);

-- Таблица упражнений
CREATE TABLE Exercises (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dayId INTEGER NOT NULL,
  exerciseNumber INTEGER NOT NULL,
  sets INTEGER NOT NULL,
  holdTime INTEGER NOT NULL,
  restTime INTEGER NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (dayId) REFERENCES TrainingDays(id) ON DELETE CASCADE
);

-- Таблица прогресса пользователя
CREATE TABLE UserProgress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  lastUpdated DATE DEFAULT CURRENT_DATE,
  currentWeight REAL,
  notes TEXT,
  FOREIGN KEY (profileId) REFERENCES Profile(id) ON DELETE CASCADE
);

-- Таблица советов
CREATE TABLE Tips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  question TEXT NOT NULL,
  answer TEXT NOT NULL,
  icon TEXT,
  isFavorite BOOLEAN DEFAULT FALSE,
  lastShownDate DATE,
  showCount INTEGER DEFAULT 0
);

-- Таблица тегов
CREATE TABLE Tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE
);

-- Таблица связи советов и тегов
CREATE TABLE TipTags (
  tipId INTEGER NOT NULL,
  tagId INTEGER NOT NULL,
  PRIMARY KEY (tipId, tagId),
  FOREIGN KEY (tipId) REFERENCES Tips(id) ON DELETE CASCADE,
  FOREIGN KEY (tagId) REFERENCES Tags(id) ON DELETE CASCADE
);

-- Таблица статей
CREATE TABLE Articles (
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

-- Таблица категорий статей
CREATE TABLE ArticleCategories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  icon TEXT
);

-- Таблица связи статей и категорий
CREATE TABLE ArticleCategoryRelations (
  articleId INTEGER NOT NULL,
  categoryId INTEGER NOT NULL,
  PRIMARY KEY (articleId, categoryId),
  FOREIGN KEY (articleId) REFERENCES Articles(id) ON DELETE CASCADE,
  FOREIGN KEY (categoryId) REFERENCES ArticleCategories(id) ON DELETE CASCADE
);

-- Таблица связи статей и тегов
CREATE TABLE ArticleTags (
  articleId INTEGER NOT NULL,
  tagId INTEGER NOT NULL,
  PRIMARY KEY (articleId, tagId),
  FOREIGN KEY (articleId) REFERENCES Articles(id) ON DELETE CASCADE,
  FOREIGN KEY (tagId) REFERENCES Tags(id) ON DELETE CASCADE
);

-- Таблица измерений веса
CREATE TABLE WeightMeasurements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  weight REAL NOT NULL,
  measurementDate DATE NOT NULL,
  trimester INTEGER,
  note TEXT,
  FOREIGN KEY (profileId) REFERENCES Profile(id) ON DELETE CASCADE
);

-- Таблица движений плода
CREATE TABLE FetalKicks (
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

-- Таблица информации по неделям беременности
CREATE TABLE PregnancyWeeks (
  weekNumber INTEGER PRIMARY KEY,
  babySize TEXT NOT NULL,
  babySizeImage TEXT NOT NULL,
  babyLength REAL,
  babyWeight REAL,
  developmentDescription TEXT,
  baby3dModel TEXT DEFAULT "logo",
);

-- Таблица советов для главного экрана
CREATE TABLE DailyTips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tipText TEXT NOT NULL,
  forTrimester INTEGER,
  tags TEXT
);

-- Таблица прогресса беременности
CREATE TABLE PregnancyProgress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  startDate DATE NOT NULL,
  currentWeek INTEGER NOT NULL,
  lastUpdated DATE NOT NULL,
  FOREIGN KEY (profileId) REFERENCES Profile(id) ON DELETE CASCADE
);

-- Таблица календаря беременности
CREATE TABLE PregnancyCalendar (
  date DATE PRIMARY KEY,
  weight REAL,
  systolicPressure INTEGER,
  diastolicPressure INTEGER,
  waistCircumference REAL,
  mood TEXT,
  notes TEXT
);

-- Таблица симптомов
CREATE TABLE Symptoms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  category TEXT
);

-- Таблица симптомов по дням
CREATE TABLE DaySymptoms (
  date DATE NOT NULL,
  symptomId INTEGER NOT NULL,
  severity INTEGER,
  notes TEXT,
  PRIMARY KEY (date, symptomId),
  FOREIGN KEY (symptomId) REFERENCES Symptoms(id) ON DELETE CASCADE
);

-- Таблица событий беременности
CREATE TABLE PregnancyEvents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  eventDate DATE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  eventType TEXT NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE
);

-- Таблица типов анализов
CREATE TABLE AnalysisTypes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,
  name TEXT NOT NULL,
  displayName TEXT,
  unit TEXT,
  minValue REAL,
  maxValue REAL,
  UNIQUE(category, name)
);

-- Таблица результатов анализов
CREATE TABLE AnalysisResults (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  analysisTypeId INTEGER NOT NULL,
  testDate DATE NOT NULL,
  value REAL NOT NULL,
  notes TEXT,
  FOREIGN KEY (analysisTypeId) REFERENCES AnalysisTypes(id) ON DELETE CASCADE
);

-- Таблица рекомендаций по анализам
CREATE TABLE AnalysisRecommendations (
  analysisTypeId INTEGER PRIMARY KEY,
  lowText TEXT,
  normalText TEXT,
  highText TEXT,
  FOREIGN KEY (analysisTypeId) REFERENCES AnalysisTypes(id) ON DELETE CASCADE
);

-- Таблица типов продуктов
CREATE TABLE ProductTypes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  icon TEXT
);

-- Таблица категорий жизненных периодов
CREATE TABLE LifeCategories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT
);

-- Таблица продуктов
CREATE TABLE Products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  typeId INTEGER NOT NULL,
  imageSource TEXT NOT NULL,
  description TEXT,
  FOREIGN KEY (typeId) REFERENCES ProductTypes(id) ON DELETE CASCADE
);

-- Таблица альтернативных названий продуктов
CREATE TABLE ProductAliases (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productId INTEGER NOT NULL,
  alias TEXT NOT NULL,
  FOREIGN KEY (productId) REFERENCES Products(id) ON DELETE CASCADE
);

-- Таблица рекомендаций по продуктам
CREATE TABLE ProductRecommendations (
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

-- Таблица диетических категорий
CREATE TABLE DietCategories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  icon TEXT NOT NULL
);

-- Таблица диет
CREATE TABLE Diets (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  number TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  categoryId INTEGER NOT NULL,
  color TEXT NOT NULL,
  icon TEXT NOT NULL,
  FOREIGN KEY (categoryId) REFERENCES DietCategories(id) ON DELETE CASCADE
);

-- Таблица деталей диет
CREATE TABLE DietDetails (
  dietId INTEGER PRIMARY KEY,
  indications TEXT NOT NULL,
  dietSchedule TEXT NOT NULL,
  notes TEXT,
  duration TEXT,
  FOREIGN KEY (dietId) REFERENCES Diets(id) ON DELETE CASCADE
);

-- Таблица рекомендуемых продуктов для диет
CREATE TABLE RecommendedFoods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dietId INTEGER NOT NULL,
  category TEXT NOT NULL,
  item TEXT NOT NULL,
  FOREIGN KEY (dietId) REFERENCES Diets(id) ON DELETE CASCADE
);

-- Таблица исключаемых продуктов для диет
CREATE TABLE ExcludedFoods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  dietId INTEGER NOT NULL,
  category TEXT NOT NULL,
  item TEXT NOT NULL,
  FOREIGN KEY (dietId) REFERENCES Diets(id) ON DELETE CASCADE
);

-- Создание индексов для ускорения запросов
CREATE INDEX idx_tasks_checklist ON Tasks(checklistId);
CREATE INDEX idx_training_days_program ON TrainingDays(programId);
CREATE INDEX idx_exercises_day ON Exercises(dayId);
CREATE INDEX idx_user_progress_profile ON UserProgress(profileId);
CREATE INDEX idx_tiptags_tip ON TipTags(tipId);
CREATE INDEX idx_tiptags_tag ON TipTags(tagId);
CREATE INDEX idx_articlecategories_relations ON ArticleCategoryRelations(articleId, categoryId);
CREATE INDEX idx_articletags_article ON ArticleTags(articleId);
CREATE INDEX idx_articletags_tag ON ArticleTags(tagId);
CREATE INDEX idx_weight_measurements_profile ON WeightMeasurements(profileId);
CREATE INDEX idx_fetal_kicks_profile ON FetalKicks(profileId);
CREATE INDEX idx_pregnancy_progress_profile ON PregnancyProgress(profileId);
CREATE INDEX idx_day_symptoms_symptom ON DaySymptoms(symptomId);
CREATE INDEX idx_analysis_results_type ON AnalysisResults(analysisTypeId);
CREATE INDEX idx_product_aliases_product ON ProductAliases(productId);
CREATE INDEX idx_product_recommendations_product ON ProductRecommendations(productId);
CREATE INDEX idx_product_recommendations_category ON ProductRecommendations(categoryId);
CREATE INDEX idx_products_type ON Products(typeId);
CREATE INDEX idx_diets_category ON Diets(categoryId);
CREATE INDEX idx_recommended_foods_diet ON RecommendedFoods(dietId);
CREATE INDEX idx_excluded_foods_diet ON ExcludedFoods(dietId);
