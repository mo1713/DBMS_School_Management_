-- DROP DATABASE school_management;
CREATE DATABASE school_management;
USE school_management;
-- DESCRIBE Class_period;
CREATE TABLE `Students`(
    `StudentID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `StudentName` VARCHAR(100) NOT NULL,
    `Address` VARCHAR(255) NOT NULL,
    `BirthDate` DATE NOT NULL,
    `Email` VARCHAR(255) NOT NULL
);
-- Tạo bảng lưu lại tọa độ của học sinh
CREATE TABLE `Student_Locations` (
  StudentID INT PRIMARY KEY,
  Latitude DECIMAL(10, 7),
  Longitude DECIMAL(10, 7),
  FOREIGN KEY (StudentID) REFERENCES Students(StudentID)
);
CREATE TABLE `Classes`(
    `ClassID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ClassName` VARCHAR(255) NOT NULL
);
CREATE TABLE `Academic_period`(
    `PerId` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Term` INT NOT NULL,
    `Year` INT NOT NULL
);
CREATE TABLE `Grades`(
    `GradeID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `SubjectID` INT NOT NULL,
    `StudentID` INT NOT NULL,
    `Score` DECIMAL(3, 1) NOT NULL,
    `Weight` INT NOT NULL,
    `PerId` INT UNSIGNED NOT NULL
);
CREATE TABLE `Teachers`(
    `TeacherID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `TeacherName` VARCHAR(255) NOT NULL,
    `SubjectID` INT NOT NULL,
    `Email` VARCHAR(255) NOT NULL
);
CREATE TABLE `Subjects`(
    `SubjectID` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `SubjectName` VARCHAR(255) NOT NULL
);
CREATE TABLE `Classes_Teacher`(
    `id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Class_perID` INT UNSIGNED NOT NULL,
    `TeacherID` INT NOT NULL
);
CREATE TABLE `Class_period`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `ClassID` INT NOT NULL,
    `PerId` INT NOT NULL,
    `Homeroom_TeacherID` INT NOT NULL
);
ALTER TABLE Class_period
MODIFY COLUMN PerID INT UNSIGNED NOT NULL;

CREATE TABLE `Students_Classes`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `StudentID` INT NOT NULL,
    `Class_perID` INT UNSIGNED NOT NULL
);

CREATE TABLE `Money`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `StudentID` INT NOT NULL,
    `PerID` INT NOT NULL,
    `Value` INT NOT NULL,
    `Paid` INT NOT NULL,
    `Debt` INT NOT NULL
);
ALTER TABLE Money
MODIFY COLUMN PerID INT UNSIGNED NOT NULL;

CREATE TABLE `Schedules`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `Class_perID` INT NOT NULL,
    `TeacherID` INT NOT NULL,
    `TimeSlotID` INT NOT NULL,
    `WeekNumber` INT NULL
);
ALTER TABLE Schedules
MODIFY COLUMN Class_perID INT UNSIGNED NOT NULL;

ALTER TABLE Schedules
MODIFY COLUMN TimeSlotID INT UNSIGNED NOT NULL;

CREATE TABLE `TimeSlots`(
    `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    `DayOfWeek` VARCHAR(255) NOT NULL,
    `StartTime` TIME NOT NULL,
    `EndTime` TIME NOT NULL
);

ALTER TABLE
    `Class_period` ADD CONSTRAINT `class_period_classid_foreign` FOREIGN KEY(`ClassID`) REFERENCES `Classes`(`ClassID`);
ALTER TABLE
    `Grades` ADD CONSTRAINT `grades_subjectid_foreign` FOREIGN KEY(`SubjectID`) REFERENCES `Subjects`(`SubjectID`);
ALTER TABLE
    `Grades` ADD CONSTRAINT `grades_studentid_foreign` FOREIGN KEY(`StudentID`) REFERENCES `Students`(`StudentID`);
ALTER TABLE
    `Grades` ADD CONSTRAINT `grades_perid_foreign` FOREIGN KEY(`PerId`) REFERENCES `Academic_period`(`PerId`);
ALTER TABLE
    `Teachers` ADD CONSTRAINT `teachers_subjectid_foreign` FOREIGN KEY(`SubjectID`) REFERENCES `Subjects`(`SubjectID`);
ALTER TABLE
    `Students_Classes` ADD CONSTRAINT `students_classes_class_perid_foreign` FOREIGN KEY(`Class_perID`) REFERENCES `Class_period`(`id`);
ALTER TABLE
    `Class_period` ADD CONSTRAINT `class_period_perid_foreign` FOREIGN KEY(`PerId`) REFERENCES `Academic_period`(`PerId`);
ALTER TABLE
    `Class_period` ADD CONSTRAINT `class_period_homeroom_teacherid_foreign` FOREIGN KEY(`Homeroom_TeacherID`) REFERENCES `Teachers`(`TeacherID`);
ALTER TABLE
    `Money` ADD CONSTRAINT `money_studentid_foreign` FOREIGN KEY(`StudentID`) REFERENCES `Students`(`StudentID`);
ALTER TABLE
    `Money` ADD CONSTRAINT `money_perid_foreign` FOREIGN KEY(`PerID`) REFERENCES `Academic_period`(`PerId`);
ALTER TABLE
    `Schedules` ADD CONSTRAINT `schedules_class_perid_foreign` FOREIGN KEY(`Class_perID`) REFERENCES `Class_period`(`id`);
ALTER TABLE
    `Students_Classes` ADD CONSTRAINT `students_classes_studentid_foreign` FOREIGN KEY(`StudentID`) REFERENCES `Students`(`StudentID`);
ALTER TABLE
    `Schedules` ADD CONSTRAINT `schedules_teacherid_foreign` FOREIGN KEY(`TeacherID`) REFERENCES `Teachers`(`TeacherID`);
ALTER TABLE
    `Classes_Teacher` ADD CONSTRAINT `classes_teacher_class_perid_foreign` FOREIGN KEY(`Class_perID`) REFERENCES `Class_period`(`id`);
ALTER TABLE
    `Schedules` ADD CONSTRAINT `schedules_timeslotid_foreign` FOREIGN KEY(`TimeSlotID`) REFERENCES `TimeSlots`(`id`);
ALTER TABLE
    `Classes_Teacher` ADD CONSTRAINT `classes_teacher_teacherid_foreign` FOREIGN KEY(`TeacherID`) REFERENCES `Teachers`(`TeacherID`);
ALTER TABLE Grades MODIFY COLUMN PerId INT UNSIGNED NOT NULL;
CREATE INDEX idx_st_name ON Students(StudentName);
CREATE INDEX idx_t_name ON Teachers(TeacherName);
CREATE INDEX idx_grad on Grades(StudentID, SubjectID);
CREATE INDEX idx_class ON Classes(ClassName);

-- Create view for class roster, top students. and subject-wise performance
CREATE VIEW class_roster AS
SELECT c.ClassName, s.StudentID, s.StudentName, s.Address, s.BirthDate
FROM Students s
INNER JOIN Students_Classes sc ON s.StudentID = sc.StudentID
INNER JOIN Class_period cp  ON cp.id = sc.Class_perID
INNER JOIN Classes c ON c.ClassID = cp.ClassID
ORDER BY c.ClassName;
SELECT * FROM class_roster;
CREATE VIEW top_10_student AS
SELECT  s.StudentID, s.StudentName, g.SubjectID, g.Score, c.ClassID
FROM Students s
INNER JOIN Grades g ON g.StudentID = s.StudentID
INNER JOIN Students_Classes sc ON s.StudentID = sc.StudentID
INNER JOIN Class_period cp  ON cp.id = sc.Class_perID
INNER JOIN Classes c ON c.ClassID = cp.ClassID
ORDER BY g.Score DESC
LIMIT 10
-- when tracking top student respect to class or subject, add where g.SubjectID = or s.ClassID -
;
SELECT * FROM top_10_student;
CREATE VIEW subject_wise_perf AS
SELECT s.StudentName, s.StudentID, g.SubjectID, g.Score, sj.SubjectName, c.ClassName
FROM Grades g
INNER JOIN Students s ON s.studentID = g.StudentID
INNER JOIN Subjects sj ON sj.SubjectID = g.SubjectID
INNER JOIN Students_Classes sc ON s.StudentID = sc.StudentID
INNER JOIN Class_period cp  ON cp.id = sc.Class_perID
INNER JOIN Classes c ON c.ClassID = cp.ClassID
ORDER BY g.SubjectID, g.Score DESC;
SELECT * FROM subject_wise_perf;
-- for tracking each subject, add where sj.SubjectID =, respect to class, c.ClassID =
;

USE school_management;

-- 1. View: per‑student scorecard (flattened grades + weighted score + GPA)
DROP VIEW IF EXISTS vw_student_scores;
CREATE VIEW vw_student_scores AS
SELECT
  g.StudentID,
  s.StudentName,
  cl.ClassName,
  ap.Term,
  ap.Year,
  subj.SubjectName,
  g.Score,
  g.Weight,
  (g.Score * g.Weight) AS WeightedScore
FROM Grades AS g
JOIN Students AS s   USING (StudentID)
JOIN Subjects AS subj USING (SubjectID)
JOIN Academic_period AS ap USING (PerId)
JOIN Class_period AS cp ON cp.PerID = g.PerId
JOIN Students_Classes AS sc ON g.StudentID = sc.StudentID AND sc.Class_perID = cp.id
JOIN Classes AS cl ON cp.ClassID = cl.ClassID;

-- SELECT * FROM vw_student_scores;
-- 2. Stored Procedure: fetch one student’s term/year report
DROP PROCEDURE IF EXISTS sp_get_scorecard;
DELIMITER $$
CREATE PROCEDURE sp_get_scorecard(
  IN p_student_id INT,
  IN p_term       INT,
  IN p_year       INT
)
BEGIN
  SELECT
    StudentID,
    StudentName,
    ClassName,
    Term,
    Year,
    SubjectName,
    Score,
    Weight,
    WeightedScore
  FROM vw_student_scores
  WHERE StudentID = p_student_id
    AND (p_term IS NULL OR Term = p_term)
    AND (p_year IS NULL OR Year = p_year)
  ORDER BY Year, Term, SubjectName;
END$$
DELIMITER ;

-- 3. View: class performance per student
DROP VIEW IF EXISTS vw_class_performance;
CREATE VIEW vw_class_performance AS
SELECT
  cl.ClassName,
  ap.Term,
  ap.Year,
  sc.StudentID,
  st.StudentName,
  subj.SubjectName,
  g.Score,
  g.Weight
FROM Grades AS g
JOIN Students AS st           USING (StudentID)
JOIN Students_Classes AS sc   USING (StudentID)
JOIN Class_period AS cp       ON sc.Class_perID = cp.id
JOIN Classes AS cl            ON cp.ClassID = cl.ClassID
JOIN Academic_period AS ap    ON cp.PerID = ap.PerId
JOIN Subjects AS subj         USING (SubjectID);

SELECT * FROM vw_class_performance;
-- 4. Stored Procedure: class summary (average & top N)
DROP PROCEDURE IF EXISTS sp_class_summary;
DELIMITER $$
CREATE PROCEDURE sp_class_summary(
  IN p_class_name VARCHAR(100),
  IN p_term       INT,
  IN p_year       INT,
  IN p_top_n      INT
)
BEGIN
  -- overall class average
  SELECT
    AVG(score * weight) / NULLIF(SUM(weight),0) AS ClassGPA
  FROM vw_class_performance
  WHERE ClassName = p_class_name
    AND Term = p_term
    AND Year = p_year
  INTO @class_gpa;
  
  SELECT @class_gpa AS ClassGPA;
  
  -- per‑student average, top N
  SELECT
    StudentID,
    StudentName,
    ROUND(AVG(score),2) AS AvgScore
  FROM vw_class_performance
  WHERE ClassName = p_class_name
    AND Term = p_term
    AND Year = p_year
  GROUP BY StudentID, StudentName
  ORDER BY AvgScore DESC
  LIMIT p_top_n;
END$$
DELIMITER ;

-- 5. View: average per subject for a class
DROP VIEW IF EXISTS vw_subject_averages;
CREATE VIEW vw_subject_averages AS
SELECT
  ClassName,
  Term,
  Year,
  SubjectName,
  ROUND(
    SUM(score * weight) / NULLIF(SUM(weight),0)
  ,2) AS SubjectAvg
FROM vw_class_performance
GROUP BY ClassName, Term, Year, SubjectName;
SELECT * FROM vw_subject_averages;
-- 6. View & SP: teacher load
DROP VIEW IF EXISTS vw_teacher_load;
CREATE VIEW vw_teacher_load AS
SELECT
  t.TeacherID,
  t.TeacherName,
  s.SubjectName,
  ap.Term,
  ap.Year,
  COUNT(DISTINCT cp.id)       AS NumClasses,
  COUNT(sc.StudentID)         AS NumStudents
FROM Teachers AS t
JOIN Classes_Teacher AS ct USING (TeacherID)
JOIN Class_period AS cp     ON ct.Class_perID = cp.id
JOIN Academic_period AS ap  ON cp.PerID = ap.PerId
JOIN Subjects AS s ON s.SubjectID = t.SubjectID
LEFT JOIN Students_Classes AS sc
  ON sc.Class_perID = cp.id
GROUP BY t.TeacherID, t.TeacherName, ap.Term, ap.Year;
SELECT * FROM vw_teacher_load;
DROP PROCEDURE IF EXISTS sp_teacher_load;
DELIMITER $$
CREATE PROCEDURE sp_teacher_load(
  IN p_term INT,
  IN p_year INT
)
BEGIN
  SELECT TeacherID, TeacherName, SubjectName, NumClasses
  FROM vw_teacher_load
  WHERE Term = p_term
    AND Year = p_year;
END$$
DELIMITER ;

-- 7. Simple UDF: compute weighted average
DROP FUNCTION IF EXISTS fn_weighted_avg;
DELIMITER $$
CREATE FUNCTION fn_weighted_avg(
  total_weighted DOUBLE,
  total_weight   DOUBLE
) RETURNS DOUBLE DETERMINISTIC
RETURN IF(total_weight=0, 0, total_weighted/total_weight);
$$
DELIMITER ;
-- 8. Store procedure for class performance per class
DROP PROCEDURE IF EXISTS sp_get_class_average_score;
DELIMITER $$

CREATE PROCEDURE sp_get_class_average_score(
  IN input_class_name VARCHAR(100),
  IN input_term INT,
  IN input_year INT
)
BEGIN
  SELECT
    ClassName,
    Term,
    Year,
    ROUND(SUM(Score * Weight) / NULLIF(SUM(Weight), 0), 2) AS AverageScore
  FROM vw_class_performance
  WHERE ClassName = input_class_name
    AND (input_term IS NULL OR Term = input_term)
    AND (input_year IS NULL OR Year = input_year)
  GROUP BY ClassName, Term, Year;
END$$

DELIMITER ;

-- 9. Store procedure for class performance per subject
DROP PROCEDURE IF EXISTS sp_class_average_per_subject;
DELIMITER $$
CREATE PROCEDURE sp_class_average_per_subject(
  IN p_class_name VARCHAR(100),
  IN p_term       INT,
  IN p_year       INT
)
BEGIN
  SELECT
    ClassName,
    Term,
    Year,
    SubjectName,
    SubjectAvg
  FROM vw_subject_averages
  WHERE ClassName = p_class_name
    AND Term = p_term
    AND Year = p_year
  ORDER BY SubjectName;
END$$
DELIMITER ;

-- 13. Create store procedure for top student overall in school
DROP PROCEDURE IF EXISTS sp_top_students_overall;
DELIMITER $$
CREATE PROCEDURE sp_top_students_overall(
  IN p_term INT,
  IN p_year INT,
  IN p_top_n INT
)
BEGIN
  SELECT
    g.StudentID,
    s.StudentName,
    cl.ClassName,
    ROUND(SUM(g.Score * g.Weight) / NULLIF(SUM(g.Weight), 0), 2) AS AverageScore
  FROM Grades g
  JOIN Students s ON g.StudentID = s.StudentID
  JOIN Academic_period ap ON g.PerId = ap.PerId
  LEFT JOIN Students_Classes sc ON g.StudentID = sc.StudentID
  LEFT JOIN Class_period cp ON sc.Class_perID = cp.id AND cp.PerId = ap.PerId
  LEFT JOIN Classes cl ON cp.ClassID = cl.ClassID
  WHERE ap.Term = p_term AND ap.Year = p_year
  GROUP BY g.StudentID, s.StudentName, cl.ClassName
  ORDER BY AverageScore DESC
  LIMIT p_top_n;
END$$
DELIMITER ;

-- 14. Create store procedure for top student overall per subject
DROP PROCEDURE IF EXISTS sp_top_students_per_subject;
DELIMITER $$
CREATE PROCEDURE sp_top_students_per_subject(
  IN p_term INT,
  IN p_year INT,
  IN p_top_n INT,
  IN p_subject_name VARCHAR(255)
)
BEGIN
  WITH ranked AS (
    SELECT
      subj.SubjectName,
      g.StudentID,
      s.StudentName,
      ROUND(SUM(g.Score * g.Weight) / NULLIF(SUM(g.Weight), 0), 2) AS AverageScore,
      ROW_NUMBER() OVER (
        PARTITION BY g.SubjectID
        ORDER BY ROUND(SUM(g.Score * g.Weight) / NULLIF(SUM(g.Weight), 0), 2) DESC
      ) AS rank_num
    FROM Grades g
    JOIN Students s ON g.StudentID = s.StudentID
    JOIN Subjects subj ON g.SubjectID = subj.SubjectID
    JOIN Academic_period ap ON g.PerId = ap.PerId
    WHERE ap.Term = p_term AND ap.Year = p_year
      AND (p_subject_name IS NULL OR p_subject_name = '' OR subj.SubjectName = p_subject_name)
    GROUP BY g.SubjectID, g.StudentID
  )
  SELECT SubjectName, StudentID, StudentName, AverageScore
  FROM ranked
  WHERE rank_num <= p_top_n
  ORDER BY SubjectName, AverageScore DESC;
END$$
DELIMITER ;


-- create trigger trg_prevent_teacher_delete
DELIMITER $$
CREATE TRIGGER trg_prevent_teacher_delete
BEFORE DELETE ON Teachers
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM Class_period WHERE Homeroom_TeacherID = OLD.TeacherID
  ) OR EXISTS (
    SELECT 1 FROM Schedules WHERE TeacherID = OLD.TeacherID
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Cannot delete teacher: they are assigned to classes or schedules.';
  END IF;
END $$
DELIMITER ;
-- create trigger trg_calc_debt_before_insert and trg_calc_debt_before_update
-- Trigger trước khi INSERT
DELIMITER $$
CREATE TRIGGER trg_calc_debt_before_insert
BEFORE INSERT ON Money
FOR EACH ROW
BEGIN
  SET NEW.Debt = NEW.Value - NEW.Paid;
END $$
DELIMITER ;

-- Trigger trước khi UPDATE
DELIMITER $$
CREATE TRIGGER trg_calc_debt_before_update
BEFORE UPDATE ON Money
FOR EACH ROW
BEGIN
  SET NEW.Debt = NEW.Value - NEW.Paid;
END $$
DELIMITER ;





# Set on_delete_cascade để tự động xóa bảng có có khóa ngoại liên quan đến dữ liệu bị xóa
;
DROP PROCEDURE IF EXISTS set_all_foreign_keys_on_delete_cascade;
DELIMITER //
CREATE PROCEDURE set_all_foreign_keys_on_delete_cascade()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE fk_table_name VARCHAR(64);
    DECLARE fk_constraint_name VARCHAR(64);
    DECLARE fk_column_name VARCHAR(64);
    DECLARE ref_table_name VARCHAR(64);
    DECLARE ref_column_name VARCHAR(64);
    
    DECLARE fk_cursor CURSOR FOR
        SELECT 
            TABLE_NAME,
            CONSTRAINT_NAME,
            COLUMN_NAME,
            REFERENCED_TABLE_NAME,
            REFERENCED_COLUMN_NAME
        FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE()
        AND REFERENCED_TABLE_NAME IS NOT NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    START TRANSACTION;

    SET FOREIGN_KEY_CHECKS = 0;

    OPEN fk_cursor;

    read_loop: LOOP
        FETCH fk_cursor INTO fk_table_name, fk_constraint_name, fk_column_name, ref_table_name, ref_column_name;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET @drop_sql = CONCAT('ALTER TABLE ', fk_table_name, ' DROP FOREIGN KEY ', fk_constraint_name);
        PREPARE stmt FROM @drop_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

        
        SET @add_sql = CONCAT(
            'ALTER TABLE ', fk_table_name, 
            ' ADD CONSTRAINT ', fk_constraint_name, 
            ' FOREIGN KEY (', fk_column_name, ')',
            ' REFERENCES ', ref_table_name, ' (', ref_column_name, ')',
            ' ON DELETE CASCADE'
        );
        PREPARE stmt FROM @add_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END LOOP;

    CLOSE fk_cursor;

    
    SET FOREIGN_KEY_CHECKS = 1;

    COMMIT;
END //

DELIMITER ;
CALL set_all_foreign_keys_on_delete_cascade();
#Trigger cho từng bảng để lưu lại các hoạt động INSERT, UPDATE, DELETE
;
-- DROP TRIGGER IF EXISTS after_academic_period_insert;
DELIMITER //
CREATE TRIGGER after_academic_period_insert
AFTER INSERT ON academic_period
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'academic_period',
        CONCAT('New record added: PerId=', NEW.PerId, ', Term=', NEW.Term, ',Year=', NEW.Year)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_academic_period_update
AFTER UPDATE ON academic_period
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'academic_period',
        CONCAT('Record updated: PerId=', NEW.PerId, 
               ', Old PerId=', OLD.PerId, ', New PerId=', NEW.PerId,
               ', Old Term=', OLD.Term, ', New Term=', NEW.Term,
               ', Old Year=', OLD.Year, ', New Year=', NEW.Year)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_academic_period_delete
AFTER DELETE ON academic_period
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'academic_period',
        CONCAT('Record deleted: PerId=', OLD.PerId, ', Term=', OLD.Term, ', Year=', OLD.Year)
    );
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER after_class_period_insert
AFTER INSERT ON class_period
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'class_period',
        CONCAT('New record added: id=', NEW.id, ', ClassID=', NEW.ClassID, ', PerId=', NEW.PerId, ', Homeroom_TeacherID=', NEW.Homeroom_TeacherID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_class_period_update
AFTER UPDATE ON class_period
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'class_period',
        CONCAT('Record updated: id=', NEW.id, 
               ', Old id=', OLD.id, ', New id=', NEW.id,
               ', Old ClassID=', OLD.ClassID, ', New ClassID=', NEW.ClassID,
               ', Old PerId=', OLD.PerId, ', New PerId=', NEW.PerId , 
               ', Old Homeroom_TeacherID=', OLD.Homeroom_TeacherID, ', New Homeroom_TeacherID=', NEW.Homeroom_TeacherID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_class_period_delete
AFTER DELETE ON class_period
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'class_period',
        CONCAT('Record deleted: id=', OLD.id,', ClassID=', OLD.ClassID, ', PerId=', OLD.PerId, ', Homeroom_TeacherID=', OLD.Homeroom_TeacherID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_classes_insert
AFTER INSERT ON classes
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'classes',
        CONCAT('New record added: ClassID=', NEW.ClassID, ', ClassName=', NEW.ClassName)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_classes_update
AFTER UPDATE ON classes
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'classes',
        CONCAT('Record updated: ClassID=', NEW.ClassID, 
               ', Old ClassID=', OLD.ClassID, ', New ClassID=', NEW.ClassID, 
               ', OLD.ClassName=', NEW.ClassName, ', NEW.ClassName=', NEW.ClassName)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_classes_delete
AFTER DELETE ON classes
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'classes',
        CONCAT('Record deleted: ClassID=', OLD.ClassID, ', ClassName=', OLD.ClassName)
    );
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER after_classes_teacher_insert
AFTER INSERT ON classes_teacher
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'classes_teacher',
        CONCAT('New record added: id=', NEW.id, ', Class_perID=', NEW.Class_perID, ',TeacherID=', NEW.TeacherID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_classes_teacher_update
AFTER UPDATE ON classes_teacher
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'classes_teacher',
        CONCAT('Record updated: id=', NEW.id, 
               ', Old id=', OLD.id, ', New id=', NEW.id,
               ', Old Class_perID=', OLD.Class_perID, ', New Class_perID=', NEW.Class_perID,
               ', Old TeacherID=', OLD.TeacherID, ', New TeacherID=', NEW.TeacherID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_classes_teacher_delete
AFTER DELETE ON classes_teacher
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'classes_teacher',
        CONCAT('Record deleted: id=', OLD.id, ', Class_perID=', OLD.Class_perID, ', TeacherID=', OLD.TeacherID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_grades_insert
AFTER INSERT ON grades
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'grades',
        CONCAT('New record added: GradeID=', NEW.GradeID, ', SubjectID=', NEW.SubjectID, ', StudentID=', NEW.StudentID, ', Score=', NEW.Score, ', Weight=', NEW.Weight, ', PerId=', NEW.perID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_grades_update
AFTER UPDATE ON grades
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'grades',
        CONCAT('Record updated: GradeID=', NEW.GradeID, 
               ', Old GradeID=', OLD.GradeID, ', New GradeID=', NEW.GradeID,
               ', Old SubjectID=', OLD.SubjectID, ', New SubjectID=', NEW.StudentID , ', Old StudentID=', OLD.StudentID, ', New StudentID=', NEW.StudentID,
               ', Old Score=', OLD.Score, ', New Score=', NEW.Score , ', Old Weight=', OLD.Weight, ', New Weight=', NEW.Weight, 
               ', Old perID=', OLD.perID, ', New perID=', NEW.perID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_grades_delete
AFTER DELETE ON grades
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'grades',
        CONCAT('Record deleted: GradeID=', OLD.GradeID,', SubjectID=', OLD.SubjectID, ', StudentID=', OLD.StudentID, ', Score=', OLD.Score, ', Weight=', OLD.Weight,  ', perID=', OLD.perID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_money_insert
AFTER INSERT ON money
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'money',
        CONCAT('New record added: id=', NEW.id, ', StudentID=', NEW.StudentID, ', PerID=', NEW.PerID, ', Value=', NEW.Value, ', Paid=', NEW.Paid, ', Debt=', NEW.Debt)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_money_update
AFTER UPDATE ON money
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'money',
        CONCAT('Record updated: id=', NEW.id, 
               ', Old id=', OLD.id, ', New id=', NEW.id,
               ', Old StudentID=', OLD.StudentID, ', New StudentID=', NEW.StudentID , ', Old PerID=', OLD.PerID, ', New PerID=', NEW.PerID,
               ', Old Value=', OLD.Value, ', New Value=', NEW.Value , ', Old Paid=', OLD.Paid, ', New Paid=', NEW.Paid, 
               ', Old Debt=', OLD.Debt, ', New Debt=', NEW.Debt)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_money_delete
AFTER DELETE ON money
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'money',
        CONCAT('Record deleted: id=', OLD.id,', StudentID=', OLD.StudentID, ', PerID=', OLD.PerID, ', Value=', OLD.Value, ', Paid=', OLD.Paid,  ', Debt=', OLD.Debt)
    );
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER after_schedules_insert
AFTER INSERT ON schedules
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'schedules',
        CONCAT('New record added: id=', NEW.id, ', Class_perID=', NEW.Class_perID, ', id=', NEW.Class_perID, ', TeacherID=', NEW.TeacherID, ', TimeSlotID=', NEW.TimeSlotID, ', WeekNumber=', NEW.WeekNumber)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_schedules_update
AFTER UPDATE ON schedules
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'schedules',
        CONCAT('Record updated: id=', NEW.id, 
               ', Old id=', OLD.id, ', New id=', NEW.id,
               ', Old Class_perID=', OLD.Class_perID, ', New Class_perID=', NEW.Class_perID,
               ', Old TeacherID=', OLD.TeacherID, ', New TeacherID=', NEW.TeacherID , ', Old TimeSlotID=', OLD.TimeSlotID, ', New TimeSlotID=', NEW.TimeSlotID, 
               ', Old WeekNumber=', OLD.WeekNumber, ', New WeekNumber=', NEW.WeekNumber)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_schedules_delete
AFTER DELETE ON schedules
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'schedules',
        CONCAT('Record deleted: id=', OLD.id,', Class_perID=', OLD.Class_perID, ', TeacherID=', OLD.TeacherID, ', TimeSlotID=', OLD.TimeSlotID, ', WeekNumber', OLD.WeekNumber)
    );
END //
DELIMITER ;


DELIMITER //
CREATE TRIGGER after_students_insert
AFTER INSERT ON students
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'students',
        CONCAT('New record added: StudentID=', NEW.StudentID, ', StudentName=', NEW.StudentName, ', StudentID=', NEW.StudentName, ', Address=', NEW.Address, ', BirthDate=', NEW.BirthDate, ', Email=', NEW.Email)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_students_update
AFTER UPDATE ON students
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'students',
        CONCAT('Record updated: StudentID=', NEW.StudentID, 
               ', Old StudentID=', OLD.StudentID, ', New StudentID=', NEW.StudentID,
               ', Old StudentName=', OLD.StudentName, ', New StudentName=', NEW.StudentName,
               ', Old Address=', OLD.Address, ', New Address=', NEW.Address , ', Old BirthDate=', OLD.BirthDate, ', New BirthDate=', NEW.BirthDate, 
               ', Old Email=', OLD.Email, ', New Email=', NEW.Email)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_students_delete
AFTER DELETE ON students
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'students',
        CONCAT('Record deleted: StudentID=', OLD.StudentID,', StudentName=', OLD.StudentName, ', Address=', OLD.Address, ', BirthDate=', OLD.BirthDate, ', Email', OLD.Email)
    );
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER after_students_classes_insert
AFTER INSERT ON students_classes
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'students_classes',
        CONCAT('New record added: id=', NEW.id, ', StudentID=', NEW.StudentID, ',Class_perID=', NEW.Class_perID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_students_classes_update
AFTER UPDATE ON students_classes
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'students_classes',
        CONCAT('Record updated: id=', NEW.id, 
               ', Old id=', OLD.id, ', New id=', NEW.id,
               ', Old StudentID=', OLD.StudentID, ', New StudentID=', NEW.StudentID,
               ', Old Class_perID=', OLD.Class_perID, ', New Class_perID=', NEW.Class_perID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_students_classes_delete
AFTER DELETE ON students_classes
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'students_classes',
        CONCAT('Record deleted: id=', OLD.id, ', StudentID=', OLD.StudentID, ', Class_perID=', OLD.Class_perID)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_subjects_insert
AFTER INSERT ON subjects
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'subjects',
        CONCAT('New record added: SubjectID=', NEW.SubjectID, ', SubjectName=', NEW.SubjectName)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_subjects_update
AFTER UPDATE ON subjects
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'subjects',
        CONCAT('Record updated: SubjectID=', NEW.SubjectID, 
               ', Old SubjectID=', OLD.SubjectID, ', New SubjectID=', NEW.SubjectID, 
               ', Old SubjectName=', OLD.SubjectName, ', New SubjectName=', NEW.SubjectName)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_subjects_delete
AFTER DELETE ON subjects
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'subjects',
        CONCAT('Record deleted: SubjectID=', OLD.SubjectID, ', SubjectName=', OLD.SubjectName)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_teachers_insert
AFTER INSERT ON teachers
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'teachers',
        CONCAT('New record added: TeacherID=', NEW.TeacherID, ', TeacherName=', NEW.TeacherName, ', SubjectID=', NEW.SubjectID, ', Email=', NEW.Email)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_teachers_update
AFTER UPDATE ON teachers
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'teachers',
        CONCAT('Record updated: TeacherID=', NEW.TeacherID, 
               ', Old TeacherID=', OLD.TeacherID, ', New TeacherID=', NEW.TeacherID,
               ', Old TeacherName=', OLD.TeacherName, ', New TeacherName=', NEW.TeacherName,
               ', Old SubjectID=', OLD.SubjectID, ', New SubjectID=', NEW.SubjectID , ', Old Email=', OLD.Email, ', New Email=', NEW.Email)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_teachers_delete
AFTER DELETE ON teachers
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'teachers',
        CONCAT('Record deleted: TeacherID=', OLD.TeacherID,', TeacherName=', OLD.TeacherName, ', SubjectID=', OLD.SubjectID, ', Email=', OLD.Email)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_timeslots_insert
AFTER INSERT ON timeslots
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'INSERT',
        'timeslots',
        CONCAT('New record added: id=', NEW.id, ', DayOfWeek=', NEW.DayOfWeek, ', StartTime=', NEW.StartTime, ', EndTime=', NEW.EndTime)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_timeslots_update
AFTER UPDATE ON timeslots
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'UPDATE',
        'timeslots',
        CONCAT('Record updated: id=', NEW.id, 
               ', Old id=', OLD.id, ', New id=', NEW.id,
               ', Old DayOfWeek=', OLD.DayOfWeek, ', New DayOfWeek=', NEW.DayOfWeek,
               ', Old StartTime=', OLD.StartTime, ', New StartTime=', NEW.StartTime , ', Old EndTime=', OLD.EndTime, ', New EndTime=', NEW.EndTime)
    );
END //
DELIMITER ;

DELIMITER //
CREATE TRIGGER after_timeslots_delete
AFTER DELETE ON timeslots
FOR EACH ROW
BEGIN
    INSERT INTO activity_log (action_type, table_name, log_message)
    VALUES (
        'DELETE',
        'timeslots',
        CONCAT('Record deleted: id=', OLD.id,', DayOfWeek=', OLD.DayOfWeek, ', StartTime=', OLD.StartTime, ', EndTime=', OLD.EndTime)
    );
END //
DELIMITER ;

#Activity_log tables
;
DROP TABLE IF EXISTS activity_log;
CREATE TABLE activity_log (
    id INT AUTO_INCREMENT PRIMARY KEY,
    action_type VARCHAR(10), -- Loại hành động: INSERT, UPDATE, DELETE
    table_name VARCHAR(50), -- Tên bảng bị ảnh hưởng
    log_message TEXT,       -- Thông tin chi tiết (dữ liệu thay đổi, thời gian, v.v.)
    log_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP -- Thời gian thực hiện
);

#Trigger cho bảng activity log
CREATE TABLE backup_trigger (
    id INT AUTO_INCREMENT PRIMARY KEY,
    trigger_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER after_activity_log_insert
AFTER INSERT ON activity_log
FOR EACH ROW
BEGIN
    INSERT INTO backup_trigger (trigger_time) VALUES (NOW());
END//

DELIMITER ;

#Các stored procedure để quản lý

-- Class management 
;
DROP PROCEDURE IF EXISTS AddClass;
-- Procedure to add a new class
DELIMITER //
CREATE PROCEDURE AddClass(
    IN p_ClassName VARCHAR(255)
)
BEGIN
    INSERT INTO classes (ClassName)
    VALUES (p_ClassName);
    SELECT LAST_INSERT_ID() AS NewClassID;
END //
DELIMITER ;
DROP PROCEDURE IF EXISTS UpdateClass;
-- Procedure to update an existing class
DELIMITER //
CREATE PROCEDURE UpdateClass(
    IN p_ClassID INT,
    IN p_ClassName VARCHAR(255)
)
BEGIN
    UPDATE classes
    SET ClassName = p_ClassName
    WHERE ClassID = p_ClassID;
    SELECT ROW_COUNT() AS AffectedRow;
END //
DELIMITER ;

-- Procedure to delete a class
DELIMITER //
CREATE PROCEDURE DeleteClass(
    IN p_ClassID INT
)
BEGIN
    DELETE FROM classes
    WHERE ClassID = p_ClassID;
    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

-- Stored Procedure to get class list with teacher and student count
DELIMITER //
CREATE PROCEDURE GetClassList(
    IN p_SearchName VARCHAR(255), -- Search by class name (NULL for all)
    IN p_Limit INT             -- Number of records to return
)
BEGIN
    SELECT 
        c.ClassID,
        c.ClassName,
        t.TeacherName AS HomeroomTeacher,
        ap.Term,
        ap.Year,
        COUNT(sc.StudentID) AS StudentCount
    FROM Classes c
    INNER JOIN Class_period cp ON c.ClassID = cp.ClassID
    INNER JOIN Teachers t ON cp.Homeroom_TeacherID = t.TeacherID
    INNER JOIN Academic_period ap ON cp.PerId = ap.PerId
    LEFT JOIN Students_Classes sc ON cp.id = sc.Class_perID
    WHERE p_SearchName IS NULL OR c.ClassName LIKE CONCAT('%', p_SearchName, '%')
    GROUP BY c.ClassID, c.ClassName, t.TeacherName, ap.Term, ap.Year
    ORDER BY c.ClassName
    LIMIT p_Limit;
END //
DELIMITER ;

--Search class
DELIMITER //
CREATE PROCEDURE FindClass(
    IN p_ClassID INT,            
    IN p_ClassName VARCHAR(255), 
    IN p_Term INT,               
    IN p_Year INT               
)
BEGIN
    SELECT 
        c.ClassID,
        c.ClassName,
        t.TeacherName AS HomeroomTeacher,
        ap.Term,
        ap.Year,
        COUNT(sc.StudentID) AS StudentCount
    FROM Classes c
    INNER JOIN Class_period cp ON c.ClassID = cp.ClassID
    INNER JOIN Teachers t ON cp.Homeroom_TeacherID = t.TeacherID
    INNER JOIN Academic_period ap ON cp.PerId = ap.PerId
    LEFT JOIN Students_Classes sc ON cp.id = sc.Class_perID
    WHERE 
        (p_ClassID IS NULL OR c.ClassID = p_ClassID)
        AND (p_ClassName IS NULL OR c.ClassName LIKE CONCAT('%', p_ClassName, '%'))
        AND (p_Term IS NULL OR ap.Term = p_Term)
        AND (p_Year IS NULL OR ap.Year = p_Year)
    GROUP BY c.ClassID, c.ClassName, t.TeacherName, ap.Term, ap.Year
    ORDER BY c.ClassName, ap.Year DESC, ap.Term;
END //
DELIMITER ;

-- Find class_id when only know class_name
DELIMITER //
CREATE PROCEDURE FindClassByName(
    IN p_ClassName VARCHAR(255),
    IN p_Term INT,
    IN p_Year INT
)
BEGIN
    SELECT 
        c.ClassID,
        c.ClassName
    FROM Classes c
    INNER JOIN Class_period cp ON c.ClassID = cp.ClassID
    INNER JOIN Academic_period ap ON ap.PerId = cp.PerId
    WHERE (p_ClassName IS NULL OR c.ClassName LIKE CONCAT('%', p_ClassName, '%'))
		AND (p_Term IS NULL OR ap.Term = p_Term)
        AND (p_Year IS NULL OR ap.Year = p_Year)
    ORDER BY c.ClassName, ap.Year, ap.Term;
END //
DELIMITER ;

-- Find class_name when just know class_id
DELIMITER //
CREATE PROCEDURE FindClassByID(
    IN p_ClassID INT,
    IN p_Term INT, 
    IN p_Year INT
)
BEGIN
    SELECT 
        c.ClassID,
        c.ClassName
    FROM Classes c
    INNER JOIN Class_period cp ON c.ClassID = cp.ClassID
    INNER JOIN Academic_period ap ON ap.PerId = cp.PerId
    WHERE (p_ClassID IS NULL OR c.ClassID = p_ClassID)
        AND (p_Term IS NULL OR ap.Term = p_Term)
        AND (p_Year IS NULL OR ap.Year = p_Year)
    ORDER BY c.ClassName, ap.Year DESC, ap.Term;
END //
DELIMITER ;

--Get class student
DELIMITER //
CREATE PROCEDURE GetClassStudents(
    IN p_ClassID INT,              -- ClassID to fetch students for
	IN p_ClassName VARCHAR(255),
    IN p_Term INT,               
    IN p_Year INT
)

BEGIN
    SELECT 
        s.StudentID,
        s.StudentName,
        s.Address,
        s.BirthDate,
        s.Email
    FROM Students s
    INNER JOIN Students_Classes sc ON s.StudentID = sc.StudentID
    INNER JOIN Class_period cp ON sc.Class_perID = cp.id
    INNER JOIN Classes c ON cp.ClassID = c.ClassID
    INNER JOIN Academic_period ap ON ap.PerId = cp.PerId
    WHERE 
        (p_ClassID IS NULL OR c.ClassID = p_ClassID)
        AND (p_ClassName IS NULL OR c.ClassName LIKE CONCAT('%', p_ClassName, '%'))
        AND (p_Term IS NULL OR ap.Term = p_Term)
        AND (p_Year IS NULL OR ap.Year = p_Year)
    GROUP BY s.StudentID, s.StudentName, s.Address, s.BirthDate, s.Email
    ORDER BY s.StudentName;
END //
DELIMITER ;
-- Class schedule
DELIMITER //
CREATE PROCEDURE GetClassSchedule(
    IN p_ClassID INT,              -- ClassID to fetch students for
	IN p_ClassName VARCHAR(255),
    IN p_Term INT,               
    IN p_Year INT
)
BEGIN
    SELECT 
        c.ClassName,
        t.TeacherName,
        s.SubjectName,
        ts.DayOfWeek,
        ts.StartTime,
        ts.EndTime,
        sch.WeekNumber
    FROM Schedules sch
    INNER JOIN Class_period cp ON sch.Class_perID = cp.id
    INNER JOIN Classes c ON cp.ClassID = c.ClassID
    INNER JOIN Academic_period ap ON cp.PerId = ap.PerId
    INNER JOIN Teachers t ON sch.TeacherID = t.TeacherID
    INNER JOIN Subjects s ON t.SubjectID = s.SubjectID
    INNER JOIN TimeSlots ts ON sch.TimeSlotID = ts.id
    WHERE 
        (p_ClassID IS NULL OR c.ClassID = p_ClassID)
        AND (p_ClassName IS NULL OR c.ClassName LIKE CONCAT('%', p_ClassName, '%'))
        AND (p_Term IS NULL OR ap.Term = p_Term)
        AND (p_Year IS NULL OR ap.Year = p_Year)
    ORDER BY ts.DayOfWeek, ts.StartTime;
END //
DELIMITER ;

-- Student_management

DELIMITER //
CREATE PROCEDURE AddStudentWithClass(
    IN p_StudentID INT,
    IN p_ClassID INT,
    IN p_Term INT,               
    IN p_Year INT
)
BEGIN
    DECLARE v_Class_perID INT;
    
    -- Find Class_perID from ClassID, Term, Year input
    SELECT cp.id INTO v_Class_perID
    FROM Classes c
    INNER JOIN Class_period cp ON c.ClassID = cp.ClassID
    INNER JOIN Academic_period ap ON cp.PerId = ap.PerId
    WHERE c.ClassID = p_ClassID
        AND ap.Term = p_Term
        AND ap.Year = p_Year
    LIMIT 1;
    
    -- Insert into students_classes
    INSERT INTO students_classes (StudentID, Class_perID)
    VALUES (p_StudentID, v_Class_perID);
    
    -- Return result
    SELECT 
        p_StudentID AS StudentID,
        v_Class_perID AS AssignedClass_perID,
        c.ClassName AS ClassName
    FROM Classes c
    WHERE c.ClassID = p_ClassID;
END //
DELIMITER ;

-- Delete student from class
DELIMITER //
CREATE PROCEDURE RemoveStudentFromClass(
    IN p_StudentID INT,
    IN p_ClassID INT,
    IN p_Term INT,               
    IN p_Year INT
)
BEGIN
    DECLARE v_Class_perID INT;
    
    -- Find Class_perID from ClassID, Term, Year input
    SELECT cp.id INTO v_Class_perID
    FROM Classes c
    INNER JOIN Class_period cp ON c.ClassID = cp.ClassID
    INNER JOIN Academic_period ap ON cp.PerId = ap.PerId
    WHERE c.ClassID = p_ClassID
        AND ap.Term = p_Term
        AND ap.Year = p_Year
    LIMIT 1;
    
    -- Delete from students_classes
    DELETE FROM students_classes 
    WHERE StudentID = p_StudentID 
        AND Class_perID = v_Class_perID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE AddStudent(
    IN p_StudentName VARCHAR(100),
    IN p_Address VARCHAR(255),
    IN p_BirthDate DATE,
    IN p_Email VARCHAR(255)
)
BEGIN
    INSERT INTO students (StudentName, Address, BirthDate, Email)
    VALUES (p_StudentName, p_Address, p_BirthDate, p_Email);
    
    SET @NewStudentID = LAST_INSERT_ID();
    SELECT 
        @NewStudentID AS NewStudentID;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS UpdateStudent;
DELIMITER //
CREATE PROCEDURE UpdateStudent(
    IN p_StudentID INT,
    IN p_StudentName VARCHAR(100),
    IN p_Address VARCHAR(255),
    IN p_BirthDate DATE,
    IN p_Email VARCHAR(255)
)
BEGIN
    UPDATE students
    SET StudentName = p_StudentName,
        Address = p_Address,
        BirthDate = p_BirthDate,
        Email = p_Email
    WHERE StudentID = p_StudentID;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;
-- Update each info of student
DELIMITER //
CREATE PROCEDURE UpdateStudentName(
    IN p_StudentID INT,
    IN p_StudentName VARCHAR(100)
)
BEGIN
    UPDATE Students
    SET StudentName = COALESCE(p_StudentName, StudentName)
    WHERE StudentID = p_StudentID;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateStudentAddress(
    IN p_StudentID INT,
    IN p_StudentName VARCHAR(255),
    IN p_Address VARCHAR(255)
)
BEGIN
    UPDATE Students
    SET Address = COALESCE(p_Address, Address)
    WHERE StudentID = p_StudentID
		AND StudentName =p_StudentName;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateStudentBirthDate(
    IN p_StudentID INT,
    IN P_StudentName VARCHAR(255),
    IN p_BirthDate DATE
)
BEGIN
    UPDATE Students
    SET BirthDate = COALESCE(p_BirthDate, BirthDate)
    WHERE StudentID = p_StudentID
		 AND StudentName = p_StudentName;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateStudentEmail(
    IN p_StudentID INT,
    IN p_StudentName VARCHAR(255),
    IN p_Email VARCHAR(255)
)
BEGIN
    UPDATE Students
    SET Email = COALESCE(p_Email, Email)
    WHERE StudentID = p_StudentID
		AND StudentName = p_StudentName;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

-- Delete student
DELIMITER //
CREATE PROCEDURE DeleteStudent(
    IN p_StudentID INT
)
BEGIN
    DELETE FROM Students
    WHERE StudentID = p_StudentID;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE FindStudentDetail(
    IN p_StudentID INT,
    IN p_StudentName VARCHAR(100)
)
BEGIN
    SELECT 
        s.StudentID,
        s.StudentName,
        s.Address,
        s.BirthDate,
        s.Email,
        c.ClassName,
        ap.Term,
        ap.Year
    FROM students s
    LEFT JOIN students_classes sc ON s.StudentID = sc.StudentID
    LEFT JOIN class_period cp ON sc.Class_perID = cp.id
    LEFT JOIN classes c ON cp.ClassID = c.ClassID
    LEFT JOIN academic_period ap ON cp.PerID = ap.PerID
    WHERE (p_StudentID IS NOT NULL AND s.StudentID = p_StudentID)
       OR (p_StudentID IS NULL AND (p_StudentName IS NULL OR s.StudentName LIKE CONCAT('%', p_StudentName, '%')))
    ORDER BY s.StudentName, ap.Year DESC, ap.Term DESC;
END //
DELIMITER ;

-- Find student_id by student_name
DELIMITER //
CREATE PROCEDURE FindStudentByName(
    IN p_StudentName VARCHAR(100)
)
BEGIN
    SELECT 
        s.StudentID,
        s.StudentName,
        s.Address,
        s.BirthDate,
        s.Email,
        c.ClassName,
        ap.Term,
        ap.Year
    FROM Students s
    LEFT JOIN Students_Classes sc ON s.StudentID = sc.StudentID
    LEFT JOIN Class_Period cp ON sc.Class_perID = cp.id
    LEFT JOIN Classes c ON cp.ClassID = c.ClassID
    LEFT JOIN Academic_Period ap ON cp.PerID = ap.PerID
    WHERE 
        p_StudentName IS NULL OR s.StudentName LIKE CONCAT('%', p_StudentName, '%')
    ORDER BY s.StudentName, ap.Year DESC, ap.Term DESC;
END //
DELIMITER ;
-- Find student_name by student_id
DELIMITER //
CREATE PROCEDURE FindStudentByID(
    IN p_StudentID INT
)
BEGIN
    SELECT 
        s.StudentID,
        s.StudentName,
        s.Address,
        s.BirthDate,
        s.Email,
        c.ClassName,
        ap.Term,
        ap.Year
    FROM Students s
    LEFT JOIN Students_Classes sc ON s.StudentID = sc.StudentID
    LEFT JOIN Class_Period cp ON sc.Class_perID = cp.id
    LEFT JOIN Classes c ON cp.ClassID = c.ClassID
    LEFT JOIN Academic_Period ap ON cp.PerID = ap.PerID
    WHERE 
        p_StudentID IS NULL OR s.StudentID = p_StudentID
    ORDER BY s.StudentName, ap.Year DESC, ap.Term DESC;
END //
DELIMITER ;

-- Add student to a class, or change class of student


-- Teacher management

DELIMITER //
CREATE PROCEDURE AddTeacher(
    IN p_TeacherName VARCHAR(255),
    IN p_SubjectID VARCHAR(255),
    IN p_Email VARCHAR(255)
)
BEGIN
    INSERT INTO teachers (TeacherName, SubjectID, Email)
    VALUES (p_TeacherName, p_SubjectID, p_Email);

    SELECT LAST_INSERT_ID() AS NewTeacherID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateTeacher(
    IN p_TeacherID INT,
    IN p_TeacherName VARCHAR(255),
    IN p_SubjectID INT,
    IN p_Email VARCHAR(255)
)
BEGIN
    UPDATE teachers
    SET TeacherName = p_TeacherName,
        SubjectID = p_SubjectID,
        Email = p_Email
    WHERE TeacherID = p_TeacherID;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

-- Update each column in teacher data
DELIMITER //
CREATE PROCEDURE UpdateTeacherName(
    IN p_TeacherID INT,
    IN p_TeacherName VARCHAR(255)
)
BEGIN
    UPDATE Teachers
    SET TeacherName = COALESCE(p_TeacherName, TeacherName)
    WHERE TeacherID = p_TeacherID;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateTeacherSubject(
    IN p_TeacherID INT,
    IN p_TeacherName VARCHAR(255),
    IN p_SubjectID INT
)
BEGIN
    UPDATE Teachers
    SET SubjectID = COALESCE(p_SubjectID, SubjectID)
    WHERE TeacherID = p_TeacherID
		AND TeacherName = p_TeacherName;
    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE UpdateTeacherEmail(
    IN p_TeacherID INT,
    IN p_TeacherName VARCHAR(255),
    IN p_Email VARCHAR(255)
)
BEGIN
    UPDATE Teachers
    SET Email = COALESCE(p_Email, Email)
    WHERE TeacherID = p_TeacherID
		AND TeacherName = p_TeacherName;

    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE DeleteTeacher(
    IN p_TeacherID INT
)
BEGIN
    DELETE FROM teachers
    WHERE TeacherID = p_TeacherID;
    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE FindTeacher(
    IN p_TeacherID INT,
    IN p_TeacherName VARCHAR(255)
)
BEGIN
    SELECT 
        t.TeacherID,
        t.TeacherName,
        t.Email,
        s.SubjectName
    FROM teachers t
    LEFT JOIN subjects s ON t.SubjectID = s.SubjectID
    WHERE (p_TeacherID IS NOT NULL AND t.TeacherID = p_TeacherID)
       OR (p_TeacherID IS NULL AND (p_TeacherName IS NULL OR t.TeacherName LIKE CONCAT('%', p_TeacherName, '%')))
    ORDER BY t.TeacherName;
END //
DELIMITER ;

-- Find teacher by name and subjectname
DELIMITER //
CREATE PROCEDURE FindTeacherByNameAndSubject(
    IN p_TeacherName VARCHAR(255),
    IN p_SubjectName VARCHAR(255)
)
BEGIN
    SELECT 
        t.TeacherID,
        t.TeacherName,
        t.Email,
        s.SubjectName
    FROM Teachers t
    LEFT JOIN Subjects s ON t.SubjectID = s.SubjectID
    WHERE 
        (p_TeacherName IS NULL OR t.TeacherName LIKE CONCAT('%', p_TeacherName, '%'))
        AND (p_SubjectName IS NULL OR s.SubjectName LIKE CONCAT('%', p_SubjectName, '%'))
    ORDER BY t.TeacherName;
END //
DELIMITER ;

-- Find teacher_id by teacher_name
DELIMITER //
CREATE PROCEDURE FindTeacherByName(
    IN p_TeacherName VARCHAR(255)
)
BEGIN
    SELECT 
        t.TeacherID,
        t.TeacherName,
        t.Email,
        s.SubjectName
    FROM Teachers t
    LEFT JOIN Subjects s ON t.SubjectID = s.SubjectID
    WHERE 
        p_TeacherName IS NULL OR t.TeacherName LIKE CONCAT('%', p_TeacherName, '%')
    ORDER BY t.TeacherName;
END //
DELIMITER ;

-- Find teacher_id by subject_name
DELIMITER //
CREATE PROCEDURE FindTeacherByTeacherID(
    IN p_TeacherID INT
)
BEGIN
	SELECT 
        t.TeacherID,
        t.TeacherName,
        t.Email,
        s.SubjectName
    FROM Teachers t
    WHERE 
        p_TeacherID IS NULL OR t.TeacherID LIKE CONCAT('%', p_TeacherID, '%')
    ORDER BY t.TeacherID;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetTeacherSchedule(
    IN p_TeacherID INT,
    IN p_Term INT,
    IN p_Year INT
)
BEGIN
    SELECT 
        t.TeacherName,
        s.SubjectName,
        c.ClassName,
        ts.DayOfWeek,
        ts.StartTime,
        ts.EndTime,
        sch.WeekNumber,
        ap.Term,
        ap.Year
    FROM schedules sch
    INNER JOIN teachers t ON sch.TeacherID = t.TeacherID
    INNER JOIN subjects s ON t.SubjectID = s.SubjectID
    INNER JOIN class_period cp ON sch.Class_perID = cp.id
    INNER JOIN classes c ON cp.ClassID = c.ClassID
    INNER JOIN timeslots ts ON sch.TimeSlotID = ts.id
    INNER JOIN academic_period ap ON cp.PerID = ap.PerID
    WHERE sch.TeacherID = p_TeacherID 
      AND ap.Term = p_Term 
      AND ap.Year = p_Year
    ORDER BY ts.DayOfWeek, ts.StartTime;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE GetAllTeachers()
BEGIN
    SELECT 
        t.TeacherID,
        t.TeacherName,
        t.Email,
        s.SubjectName
    FROM teachers t
    LEFT JOIN subjects s ON t.SubjectID = s.SubjectID
    ORDER BY t.TeacherName;
END //
DELIMITER ;

-- Grade Management
-- Find grade info of a student
DELIMITER //
CREATE PROCEDURE FindGradeByStudent (
    IN p_StudentID INT,
    IN p_SubjectID INT,
    IN p_Term INT,
    IN p_Year INT
)
BEGIN
    SELECT 
        g.GradeID,
        g.Score,
        g.PerId,
        ap.Term,
        ap.Year
    FROM grades g
    INNER JOIN Academic_Period ap ON g.PerId = ap.PerID
    WHERE g.StudentID = p_StudentID
        AND g.SubjectID = p_SubjectID
        AND (p_Term IS NULL OR ap.Term = p_Term)
        AND (p_Year IS NULL OR ap.Year = p_Year)
    ORDER BY ap.Year DESC, ap.Term DESC;
END //
DELIMITER ;

-- Stored Procedure to Update a Grade
DELIMITER //
CREATE PROCEDURE UpdateGrade (
    IN p_GradeID INT,
    IN p_Score DECIMAL(3,1),
    IN p_Weight INT, 
    IN p_Term INT, 
    IN p_Year INT
)
BEGIN
    UPDATE grades
    SET 
        Score = p_Score,
        Weight = p_Weight
    WHERE GradeID = p_GradeID;
END //
DELIMITER ;

-- Add a Grade
DELIMITER //
CREATE PROCEDURE AddGrade (
    IN p_SubjectID INT,
    IN p_StudentID INT,
    IN p_Score DECIMAL(3,1),
    IN p_Weight INT,
    IN p_Term INT,
    IN p_Year INT
)
BEGIN
	DECLARE v_PerId INT;
    SELECT PerId INTO v_PerId
    FROM Academic_period ap
    WHERE Term = COALESCE(p_Term, Term)
		AND Year = COALESCE(p_Year, Year)
	LIMIT 1;
    IF v_PerId IS NOT NULL THEN 
		INSERT INTO grades (SubjectID, StudentID, Score, Weight, PerId)
		VALUES (p_SubjectID, p_StudentID, p_Score, p_Weight, v_PerId);
	END IF;
    SELECT ROW_COUNT() AS AffectedRows;
END //
DELIMITER ;

-- Money management
-- Tổng thu và tổng nợ theo từng kỳ học
DELIMITER $$
CREATE PROCEDURE sp_fee_summary_by_period(IN p_term INT,  IN p_year INT)
BEGIN
    SELECT 
        ap.Term,
        ap.Year,
        SUM(m.Value) AS TotalValue,
        SUM(m.Paid) AS TotalPaid,
        SUM(m.Debt) AS TotalDebt
    FROM Money m
    JOIN Academic_period ap ON m.PerID = ap.PerId
    WHERE ap.Term = p_Term
      AND ap.Year = p_Year;

END$$
DELIMITER ;

-- Tổng thu và nợ của mỗi học sinh 
DELIMITER $$
CREATE PROCEDURE sp_total_by_student(IN p_studentID INT)
BEGIN
    SELECT 
        s.StudentID AS StudentID,
        s.StudentName AS StudentName,
        SUM(m.Value) AS TotalFee,
        SUM(m.Paid) AS TotalPaid,
        SUM(m.Debt) AS TotalDebt
    FROM money m
    JOIN students s ON m.StudentID = s.StudentID
    WHERE s.StudentID = p_studentID
    GROUP BY m.StudentID
    ORDER BY s.StudentName;
END$$
DELIMITER ;

-- Chi tiết học phí của một học sinh theo từng kỳ học 
DELIMITER $$
CREATE PROCEDURE sp_fee_detail_by_student(IN p_StudentID INT)
BEGIN
    SELECT 
        ap.Term,
        ap.Year,
        m.Value,
        m.Paid,
        m.Debt
    FROM Money m
    JOIN Academic_period ap ON m.PerID = ap.PerId
    WHERE m.StudentID = p_StudentID
    ORDER BY ap.Year, ap.Term;
END$$
DELIMITER ;

-- Bảng tiền của lớp theo kỳ học 
DELIMITER $$
CREATE PROCEDURE sp_fee_by_class_term_year(IN p_ClassID INT , IN p_Term INT, IN p_Year INT)
BEGIN
    SELECT 
        c.ClassName,
        s.StudentID,
        s.StudentName,
        ap.Term,
        ap.Year,
        m.Value AS FeeValue,
        m.Paid AS FeePaid,
        m.Debt AS FeeDebt
    FROM Money m
    JOIN Students s ON m.StudentID = s.StudentID
    JOIN Academic_period ap ON m.PerID = ap.PerId
    JOIN Students_Classes sc ON s.StudentID = sc.StudentID
    JOIN Class_period cp ON sc.Class_perID = cp.id
    JOIN Classes c ON cp.ClassID = c.ClassID
    WHERE c.ClassID = p_ClassID
      AND ap.Term = p_Term
      AND ap.Year = p_Year
    ORDER BY c.ClassName, s.StudentName;
END$$
DELIMITER ;

-- Tổng kết học phí theo lớp
DELIMITER $$
CREATE PROCEDURE sp_fee_total_by_class(IN p_ClassID INT, IN p_Term INT, IN p_Year INT)
BEGIN
    SELECT 
        c.ClassName,
        SUM(m.Value) AS TotalValue,
        SUM(m.Paid) AS TotalPaid,
        SUM(m.Debt) AS TotalDebt
    FROM Money m
    JOIN Students s ON m.StudentID = s.StudentID
    JOIN Academic_period ap ON m.PerID = ap.PerId
    JOIN Students_Classes sc ON s.StudentID = sc.StudentID
    JOIN Class_period cp ON sc.Class_perID = cp.id
    JOIN Classes c ON cp.ClassID = c.ClassID
    WHERE c.ClassID = p_ClassID
      AND ap.Term = p_Term
      AND ap.Year = p_Year
    GROUP BY c.ClassID, c.ClassName
    ORDER BY c.ClassName;
END$$
DELIMITER ;

DROP USER 'student'@'localhost';
DROP USER 'homeroom_teacher'@'localhost' ;
DROP USER 'subject_teacher'@'localhost';
DROP USER 'academic_coordinator'@'localhost';
DROP USER 'admin_user'@'localhost' ;
-- TẠO NGƯỜI DÙNG
CREATE USER 'student'@'localhost' IDENTIFIED BY 'student123';
CREATE USER 'homeroom_teacher'@'localhost' IDENTIFIED BY 'teacher123';
CREATE USER 'subject_teacher'@'localhost' IDENTIFIED BY 'subject123';
CREATE USER 'academic_coordinator'@'localhost' IDENTIFIED BY 'coordinator123';
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'admin123';

-- HỌC SINH: chỉ xem được thông tin cá nhân, điểm và học phí của mình
GRANT SELECT ON school_management.Students TO 'student'@'localhost';
GRANT SELECT ON school_management.Grades TO 'student'@'localhost';
GRANT SELECT ON school_management.Money TO 'student'@'localhost';

-- GIÁO VIÊN BỘ MÔN:
-- Được phép xem học sinh, lớp, môn học
GRANT SELECT ON school_management.Students TO 'subject_teacher'@'localhost';
GRANT SELECT ON school_management.Classes TO 'subject_teacher'@'localhost';
GRANT SELECT ON school_management.Subjects TO 'subject_teacher'@'localhost';
-- Được phép cập nhật điểm (chỉ cột Score)
GRANT SELECT, INSERT, UPDATE (Score) ON school_management.Grades TO 'subject_teacher'@'localhost';

-- GIÁO VIÊN CHỦ NHIỆM:
GRANT SELECT, INSERT, UPDATE, DELETE ON school_management.Students TO 'homeroom_teacher'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON school_management.Classes TO 'homeroom_teacher'@'localhost';
GRANT SELECT ON school_management.Grades TO 'homeroom_teacher'@'localhost';
GRANT SELECT ON school_management.Money TO 'homeroom_teacher'@'localhost';

-- HIỆU PHÓ:
-- Quản lý thông tin toàn diện về lớp, môn, học sinh, điểm và học phí
GRANT SELECT, UPDATE ON school_management.Students TO 'academic_coordinator'@'localhost';
GRANT SELECT, UPDATE ON school_management.Grades TO 'academic_coordinator'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON school_management.Classes TO 'academic_coordinator'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON school_management.Subjects TO 'academic_coordinator'@'localhost';
GRANT SELECT ON school_management.Money TO 'academic_coordinator'@'localhost';

-- ADMIN: toàn quyền với toàn bộ hệ thống
GRANT ALL PRIVILEGES ON school_management.* TO 'admin_user'@'localhost';

-- ÁP DỤNG PHÂN QUYỀN
FLUSH PRIVILEGES;