USE master;
GO

IF EXISTS(SELECT 1 FROM sys.databases WHERE name ='GraphDB')
BEGIN
    ALTER DATABASE GraphDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GraphDB;
END;
GO 

CREATE DATABASE GraphDB;
GO

USE GraphDB;
GO


--узлы
CREATE TABLE [Химикат] (
    [ID химиката] Int NOT NULL,
    [Название] Nvarchar(100) NOT NULL,
    [Формула] Nvarchar(100) NULL,
    [Регистрационный_номер_CAS] Nvarchar(20) NULL,
    [Класс опасности] Nvarchar(40) NULL,
    [Мин. температура хранения, °C] Numeric(5,2) NULL,
    [Макс. температура хранения, °C] Numeric(5,2) NULL,
    CONSTRAINT [PK_Химикат] PRIMARY KEY ([ID химиката])
) AS NODE;

CREATE TABLE [Лаборант] (
    [ID лаборанта] Int NOT NULL,
    [Имя лаборанта] Nvarchar(70) NOT NULL,
    [Фамилия лаборанта] Nvarchar(40) NULL,
    [Должность] Nvarchar(40) NULL,
    [Специализация] Nvarchar(40) NULL,
    CONSTRAINT [PK_Лаборант] PRIMARY KEY ([ID лаборанта])
) AS NODE;

CREATE TABLE [Лабораторный тест] (
    [ID теста] Int IDENTITY(1,1) NOT NULL,
    [Название теста] Nvarchar(100) NOT NULL,
    [Стандарт (ГОСТ, ISO, ASTM)] Nvarchar(100) NULL,
    [Температура проведения] Numeric(5,2) NULL,
    [Описание методики] Nvarchar(200) NULL,
    [Стоимость] Money NULL,
    CONSTRAINT [PK_Лабораторный тест] PRIMARY KEY ([ID теста])
) AS NODE;
GO

-- ребра
CREATE TABLE [Performs] (
    [Дата проведения] Datetime NULL,
    [Статус] Nvarchar(30) NULL
) AS EDGE;

ALTER TABLE [Performs] ADD CONSTRAINT [EC_Technician_Performs_Test] 
CONNECTION ([Лаборант] TO [Лабораторный тест]);

CREATE TABLE [ConsistsOf] (
    [Количество вещества] Numeric(18,0) NULL,
    [Порядок добавления] Int NULL
) AS EDGE;

ALTER TABLE [ConsistsOf] ADD CONSTRAINT [EC_ConsistsOf_Chemical] 
CONNECTION ([Лабораторный тест] TO [Химикат], [Химикат] TO [Химикат]);

CREATE TABLE [Рекомендует] (
    [Рейтинг] Int NULL,
    [Причина] Nvarchar(100) NULL
) AS EDGE;

ALTER TABLE [Рекомендует] ADD CONSTRAINT [EC_Technician_Recommends_Technician] 
CONNECTION ([Лаборант] TO [Лаборант]);
GO


INSERT INTO [Лаборант] ([ID лаборанта], [Имя лаборанта], [Фамилия лаборанта], [Должность], [Специализация])
VALUES 
(1, N'Маргарита', N'Высоцкая', N'Заведующий', N'Общая химия'),
(2, N'Александр', N'Козлов', N'Старший лаборант', N'Токсикология'),
(3, N'Ксения', N'Куцевич', N'Стажёр', N'Биохимия'),
(4, N'Андрей', N'Нелюб', N'Лаборант', N'Аналитика'),
(5, N'Анастасия', N'Маевская', N'Техник', N'Радиохимия'),
(6, N'Владислав', N'Арутюнян', N'Лаборант', N'Фармакология'),
(7, N'Надежда', N'Харина', N'Стажёр', N'Органическая химия'),
(8, N'Евгений', N'Кривошеев', N'Старший лаборант', N'Неорганика'),
(9, N'Дарья', N'Дубовцова', N'Лаборант', N'Экология'),
(10, N'Дмитрий', N'Семёнов', N'Зам.зав', N'Микробиология'),
(11, N'Алексей', N'Филюта', N'Лаборант', N'Биохимия'),
(12, N'Дмитрий', N'Панченко', N'Лаборант', N'Фармакология');

INSERT INTO [Лабораторный тест] ([Название теста], [Стоимость])
VALUES 
(N'Анализ на тяжелые металлы', 150),
(N'Тест на кислотность почвы', 400),
(N'Экспертиза состава сточных вод', 250),
(N'Биохимический анализ крови', 800),
(N'Проверка на пестициды', 120),
(N'Анализ качества топлива', 300),
(N'Микробиологический посев', 950),
(N'Радиологический контроль', 450),
(N'Тест на содержание спирта', 600),
(N'Анализ состава сплава', 180);

INSERT INTO [Химикат] ([ID химиката], [Название], [Класс опасности])
VALUES 
(101, N'Дистиллированная вода', N'Нет'),
(102, N'Серная кислота', N'Высокий'),
(103, N'Нитрат серебра', N'Средний'),
(104, N'Ртуть', N'Высокий'),
(105, N'Этиловый спирт', N'Средний'),
(106, N'Фенолфталеин', N'Нет'),
(107, N'Реагент А-1', N'Средний'), 
(108, N'Индикаторная смесь', N'Нет'),
(109, N'Раствор Люголя', N'Средний'),
(110, N'Хлорид натрия', N'Нет');
GO



INSERT INTO [Performs] ($from_id, $to_id, [Дата проведения], [Статус])
VALUES 
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 1), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Радиологический контроль'), '2026-05-10', N'Завершено'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 2), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Биохимический анализ крови'), '2026-05-02', N'Завершено'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 3), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Анализ на тяжелые металлы'), '2026-05-01', N'Завершено'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 4), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Тест на кислотность почвы'), '2026-05-10', N'Завершено'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 5), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Экспертиза состава сточных вод'), '2026-05-12', N'Завершено'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 6), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Анализ качества топлива'), '2026-05-12', N'Завершено'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 7), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Анализ качества топлива'), '2026-05-05', N'В процессе'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 8), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Анализ состава сплава'), '2026-05-13', N'В процессе'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 9), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Проверка на пестициды'), '2026-05-14', N'Завершено'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 10), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Микробиологический посев'), '2026-05-15', N'Завершено'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 11), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Тест на содержание спирта'), '2026-05-15', N'В процессе'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 12), (SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Биохимический анализ крови'), '2026-05-16', N'Завершено');

--  Тесты с Химикатами и Химикаты между собой
INSERT INTO [ConsistsOf] ($from_id, $to_id, [Количество вещества], [Порядок добавления])
VALUES 
((SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Анализ на тяжелые металлы'), (SELECT $node_id FROM [Химикат] WHERE [Название] = N'Ртуть'), 10, 1),
((SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Биохимический анализ крови'), (SELECT $node_id FROM [Химикат] WHERE [Название] = N'Реагент А-1'), 5, 1),
((SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Анализ качества топлива'), (SELECT $node_id FROM [Химикат] WHERE [Название] = N'Серная кислота'), 15, 1),
((SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Тест на кислотность почвы'), (SELECT $node_id FROM [Химикат] WHERE [Название] = N'Фенолфталеин'), 2, 1),
((SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Экспертиза состава сточных вод'), (SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 101), 500, 1),
((SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Анализ состава сплава'), (SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 103), 5, 1),
((SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Тест на содержание спирта'), (SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 108), 2, 1),
((SELECT $node_id FROM [Лабораторный тест] WHERE [Название теста] = N'Микробиологический посев'), (SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 109), 10, 1),

-- Иерархия химикатов
((SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 107), (SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 105), 50, 1),
((SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 107), (SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 102), 10, 2),
((SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 109), (SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 105), 20, 1),
((SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 108), (SELECT $node_id FROM [Химикат] WHERE [ID химиката] = 106), 5, 1);

-- Рекомендации (для цепочек SHORTEST_PATH)
INSERT INTO [Рекомендует] ($from_id, $to_id, [Рейтинг], [Причина])
VALUES 
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 1), (SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 2), 5, N'Опыт'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 1), (SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 3), 5, N'Перспективный стажер'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 2), (SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 3), 4, N'Талант'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 2), (SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 7), 4, N'Отличная работа'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 3), (SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 7), 5, N'Рост'),
((SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 7), (SELECT $node_id FROM [Лаборант] WHERE [ID лаборанта] = 11), 4, N'Рекомендация');
GO

-- 5

-- сотрудник - тест - реактив 
SELECT 
    L.[Имя лаборанта] + ' ' + L.[Фамилия лаборанта] AS [Сотрудник],
    T.[Название теста] AS [Работа],
    C.[Название] AS [Реактив]
FROM [Лаборант] L, [Performs] P, [Лабораторный тест] T, [ConsistsOf] CO, [Химикат] C
WHERE MATCH(L-(P)->T-(CO)->C);

-- тест - сложный реагент - базовый компонент
SELECT 
    T.[Название теста] AS [Тест],
    C1.[Название] AS [Сложный реагент],
    C2.[Название] AS [Базовый компонент]
FROM [Лабораторный тест] T, [ConsistsOf] CO1, [Химикат] C1, [ConsistsOf] CO2, [Химикат] C2
WHERE MATCH(T-(CO1)->C1-(CO2)->C2);

-- наставник - ученик - его тест
SELECT 
    L1.[Имя лаборанта] AS [Кто рекомендовал],
    L2.[Имя лаборанта] AS [Кого рекомендовал],
    T.[Название теста] AS [Текущий тест ученика]
FROM [Лаборант] L1, [Рекомендует] R, [Лаборант] L2, [Performs] P, [Лабораторный тест] T
WHERE MATCH(L1-(R)->L2-(P)->T);

-- работа с опасными веществами через рекомендации
SELECT DISTINCT
    L1.[Имя лаборанта] AS [Наставник],
    L2.[Имя лаборанта] AS [Исполнитель],
    C.[Название] AS [Опасное вещество]
FROM [Лаборант] L1, [Рекомендует] R, [Лаборант] L2, [Performs] P, [Лабораторный тест] T, [ConsistsOf] CO, [Химикат] C
WHERE MATCH(L1-(R)->L2-(P)->T-(CO)->C)
  AND C.[Класс опасности] = N'Высокий';

-- дорогие тесты > 500 и их исполнители
SELECT 
    L.[Фамилия лаборанта] AS [Исполнитель],
    T.[Название теста] AS [Дорогой тест],
    T.[Стоимость]
FROM [Лаборант] L, [Performs] P, [Лабораторный тест] T, [ConsistsOf] CO, [Химикат] C
WHERE MATCH(L-(P)->T-(CO)->C)
  AND T.[Стоимость] > 500;
GO

-- 6

SELECT 
    L1.[Имя лаборанта] AS [Начало пути],
    STRING_AGG(L2.[Имя лаборанта], ' -> ') WITHIN GROUP (GRAPH PATH) AS [Цепочка рекомендаций],
    COUNT(L2.[Имя лаборанта]) WITHIN GROUP (GRAPH PATH) AS [Длина пути]
FROM 
    [Лаборант] AS L1,
    [Рекомендует] FOR PATH AS R,
    [Лаборант] FOR PATH AS L2
WHERE MATCH(SHORTEST_PATH(L1(-(R)->L2)+))
AND L1.[Имя лаборанта] = N'Маргарита';


SELECT 
    T.[Название теста] AS [Тест],
    STRING_AGG(C.[Название], ' содержит ') WITHIN GROUP (GRAPH PATH) AS [Состав],
    COUNT(C.[Название]) WITHIN GROUP (GRAPH PATH) AS [Уровней вложенности]
FROM 
    [Лабораторный тест] AS T,
    [ConsistsOf] FOR PATH AS CO,
    [Химикат] FOR PATH AS C
WHERE MATCH(SHORTEST_PATH(T(-(CO)->C){1,5}))
AND T.[Название теста] = N'Анализ на тяжелые металлы';
GO