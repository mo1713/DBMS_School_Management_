USE school_management;


INSERT INTO `Students` (`StudentName`, `Address`, `BirthDate`, `Email`) VALUES
('Alice Nguyen', '123 Main St, Hanoi', '2000-05-01', 'alice.nguyen@example.com'),
('Bob Tran', '456 Oak St, Hanoi', '1999-07-20', 'bob.tran@example.com'),
('Charlie Le', '789 Pine St, Hanoi', '2001-02-15', 'charlie.le@example.com'),
('Diana Pham', '321 Maple St, Hanoi', '1998-10-10', 'diana.pham@example.com'),
('Ethan Do', '654 Birch St, Hanoi', '2000-12-25', 'ethan.do@example.com');






INSERT INTO `Classes` (`ClassName`) VALUES
('Math 101'),
('Physics 102'),
('Chemistry 103'),
('Biology 104'),
('Computer Science 105');




INSERT INTO `Subjects` (`SubjectName`) VALUES
('Math'),
('Physics'),
('Chemistry'),
('Biology'),
('Computer Science');


INSERT INTO `Academic_period` (`Term`, `Year`) VALUES
(1, 2023),
(2, 2023),
(1, 2024),
(2, 2024),
(1, 2025);


INSERT INTO `Teachers` (`TeacherName`, `SubjectID`, `Email`) VALUES
('Mr. A', 1, 'mr.a@example.com'),
('Ms. B', 2, 'ms.b@example.com'),
('Dr. C', 3, 'dr.c@example.com'),
('Prof. D', 4, 'prof.d@example.com'),
('Dr. E', 5, 'dr.e@example.com');


INSERT INTO `Grades` (`SubjectID`, `StudentID`, `Score`, `Weight`, `perID`) VALUES
(1, 1, 88.5, 3, 1),
(2, 2, 92.0, 3, 1),
(3, 3, 78.0, 2, 1),
(4, 4, 85.5, 4, 1),
(5, 5, 91.5, 3, 1);




INSERT INTO `Class_period` (`ClassID`, `PerId`, `Homeroom_TeacherID`) VALUES
(1, 1, 1),
(2, 1, 2),
(3, 1, 3),
(4, 1, 4),
(5, 1, 5);


INSERT INTO `Students_Classes` (`StudentID`, `Class_perID`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);


INSERT INTO `Classes_Teacher` (`Class_perID`, `TeacherID`) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);







INSERT INTO `Money` (`StudentID`, `PerID`, `Value`, `Paid`, `Debt`) VALUES
(1, 1, 1000, 500, 500),
(2, 1, 1200, 600, 600),
(3, 1, 800, 400, 400),
(4, 1, 950, 450, 500),
(5, 1, 1100, 550, 550);




INSERT INTO `TimeSlots` (`DayOfWeek`, `StartTime`, `EndTime`) VALUES
('Monday', '08:00:00', '10:00:00'),
('Tuesday', '10:00:00', '12:00:00'),
('Wednesday', '14:00:00', '16:00:00'),
('Thursday', '16:00:00', '18:00:00'),
('Friday', '08:00:00', '10:00:00');




INSERT INTO `Schedules` (`Class_perID`, `TeacherID`, `TimeSlotID`, `WeekNumber`) VALUES
(1, 1, 1, 1),
(2, 2, 2, 2),
(3, 3, 3, 3),
(4, 4, 4, 4),
(5, 5, 5, 5);





























