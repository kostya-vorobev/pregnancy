BEGIN TRANSACTION;
CREATE TABLE IF NOT EXISTS AnalysisRecommendations (
  analysisTypeId INTEGER PRIMARY KEY,
  lowText TEXT,
  normalText TEXT,
  highText TEXT,
  FOREIGN KEY (analysisTypeId) REFERENCES AnalysisTypes(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS AnalysisResults (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  analysisTypeId INTEGER NOT NULL,
  testDate DATE NOT NULL,
  value REAL NOT NULL,
  notes TEXT,
  FOREIGN KEY (analysisTypeId) REFERENCES AnalysisTypes(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS AnalysisTypes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  category TEXT NOT NULL,
  name TEXT NOT NULL,
  displayName TEXT,
  unit TEXT,
  minValue REAL,
  maxValue REAL,
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
CREATE TABLE IF NOT EXISTS DailyTips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tipText TEXT NOT NULL,
  forTrimester INTEGER,
  tags TEXT
);
CREATE TABLE IF NOT EXISTS DaySymptoms (
  date DATE NOT NULL,
  symptomId INTEGER NOT NULL,
  severity INTEGER,
  notes TEXT,
  PRIMARY KEY (date, symptomId),
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
CREATE TABLE IF NOT EXISTS PregnancyCalendar (
  date DATE PRIMARY KEY,
  weight REAL,
  systolicPressure INTEGER,
  diastolicPressure INTEGER,
  waistCircumference REAL,
  mood TEXT,
  notes TEXT
);
CREATE TABLE IF NOT EXISTS PregnancyEvents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  eventDate DATE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  eventType TEXT NOT NULL,
  isCompleted BOOLEAN DEFAULT FALSE
);
CREATE TABLE IF NOT EXISTS PregnancyProgress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  profileId INTEGER NOT NULL,
  startDate DATE NOT NULL,
  currentWeek INTEGER NOT NULL,
  lastUpdated DATE NOT NULL,
  FOREIGN KEY (profileId) REFERENCES Profile(id) ON DELETE CASCADE
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
INSERT INTO "PregnancyProgress" ("id","profileId","startDate","currentWeek","lastUpdated") VALUES (4,1,'2025-05-17',4,'2025-05-18');
INSERT INTO "PregnancyWeeks" ("weekNumber","babySize","babySizeImage","babyLength","babyWeight","developmentDescription","baby3dModel") VALUES (1,'Мак','poppy',0.1,0.0,'Оплодотворение яйцеклетки и начало деления клеток','logo'),
 (4,'Горошина','peas',0.5,0.5,'Формирование нервной трубки и сердца','logo'),
 (12,'Лимон','lemon',6.0,14.0,'Сформированы все основные органы','logo'),
 (20,'Банан','banana',16.0,300.0,'Плод начинает слышать','logo'),
 (40,'Тыква','pumpkin',51.0,3400.0,'Готов к рождению','logo');
INSERT INTO "Profile" ("id","firstName","lastName","dateBirth","height","weight","bloodType","profilePhoto","currentProgramId","initialWeight","prePregnancyWeight","weightGainGoal","middleName") VALUES (1,'Воробьева','Анастасия','2025-05-18',180,75.0,'A+',NULL,NULL,0.0,0.0,0.0,'Владимировна');
CREATE INDEX idx_analysis_results_type ON AnalysisResults(analysisTypeId);
CREATE INDEX idx_articlecategories_relations ON ArticleCategoryRelations(articleId, categoryId);
CREATE INDEX idx_articletags_article ON ArticleTags(articleId);
CREATE INDEX idx_articletags_tag ON ArticleTags(tagId);
CREATE INDEX idx_day_symptoms_symptom ON DaySymptoms(symptomId);
CREATE INDEX idx_diets_category ON Diets(categoryId);
CREATE INDEX idx_excluded_foods_diet ON ExcludedFoods(dietId);
CREATE INDEX idx_exercises_day ON Exercises(dayId);
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
CREATE INDEX idx_training_days_program ON TrainingDays(programId);
CREATE INDEX idx_user_progress_profile ON UserProgress(profileId);
CREATE INDEX idx_weight_measurements_profile ON WeightMeasurements(profileId);
COMMIT;
