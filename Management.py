import mysql.connector
from mysql.connector import Error
import pandas as pd
import os
import tempfile
from dotenv import load_dotenv

# Tải biến môi trường từ file .env
load_dotenv()

class Manager:
    @staticmethod
    def connect_db():
        try:
            connection = mysql.connector.connect(
                host=os.getenv("DB_HOST"),
                user=os.getenv("DB_USER"),
                password=os.getenv("DB_PASS"),
                database=os.getenv("DB_NAME")
            )
            if connection.is_connected():
                print("Connected to MySQL database")
                return connection
        except Error as e:
            print(f"Error connecting to MySQL: {e}")
            return None

    @staticmethod
    def fetch_data(query):
        connection = Manager.connect_db()
        if connection:
            try:
                # Sử dụng pandas để đọc dữ liệu từ truy vấn SQL
                df = pd.read_sql(query, connection)
                return df
            except Error as e:
                print(f"Error executing query: {e}")
                return None
            finally:
                connection.close()
                print("MySQL connection closed")
        return None
    @staticmethod
    def get_all_term():
        query = "SELECT DISTINCT Term FROM Academic_period"
        df = Manager.fetch_data(query)
        try:
            result = tuple(row['Term'] for _,row in df.iterrows())
            return result
        except Exception as e:
            return(f"Error: {e}")
        
    @staticmethod
    @staticmethod
    def get_all_year():
        query = "SELECT DISTINCT Year FROM Academic_period"
        df = Manager.fetch_data(query)
        try:
            result = tuple(row['Year'] for _,row in df.iterrows())
            return result
        except Exception as e:
            return(f"Error: {e}")
        

    @staticmethod
    def get_all_classes():
        query = "SELECT ClassID, ClassName FROM Classes"
        df = Manager.fetch_data(query)
        if df is not None and not df.empty:
            result = tuple(f"{row['ClassID']}, {row['ClassName']}" for _, row in df.iterrows())
            return result
        return ()

    @staticmethod
    def add_class(class_name):
        try:
            conn = Manager.connect_db()
            cursor = conn.cursor()
            cursor.callproc('AddClass', [class_name])
            for result in cursor.stored_results():
                new_id = result.fetchone()[0]
            conn.commit()
        except Error as e:
            print(f"Error: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    # Update a class
    @staticmethod
    def update_class(class_id, class_name):
        try:
            conn = Manager.connect_db()
            cursor = conn.cursor()
            cursor.callproc('UpdateClass', [class_id, class_name])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            return(f"Error: {e}")
        finally:
            cursor.close()
            conn.close()

    # Delete a class
    @staticmethod
    def delete_class(class_id):
        try:
            conn = Manager.connect_db()
            cursor = conn.cursor()
            cursor.callproc('DeleteClass', [class_id])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error: {e}")
            return 0
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_class_list(search_name=None, limit=10):
        """
        Retrieve a list of classes with homeroom teacher, academic period, student count, and notes.
        
        Args:
            search_name (str, optional): Filter classes by name (partial match).
            limit (int): Number of records to return.
        
        Returns:
            pandas.DataFrame: DataFrame containing class details.
        """
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('GetClassList', [search_name, limit])
            classes = []
            for result in cursor.stored_results():
                classes = result.fetchall()
            # Convert list of dictionaries to DataFrame
            df = pd.DataFrame(classes)
            return df
        except Error as e:
            print(f"Error executing GetClassList: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def find_class(class_id=None, class_name=None, Term=None, Year=None):
        """
        Find classes by ClassID or ClassName.
        
        Args:
            class_id (int, optional): Exact ClassID to search for.
            class_name (str, optional): Partial ClassName to search for.
        
        Returns:
            pandas.DataFrame: DataFrame containing matching class details (ClassID, ClassName, Notes, 
                            HomeroomTeacher, Term, Year, StudentCount).
        """
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            # Ensure class_id is None if not provided or invalid
            class_id = class_id if class_id is not None else None
            cursor.callproc('FindClass', [class_id, class_name, Term, Year])
            classes = []
            for result in cursor.stored_results():
                classes = result.fetchall()
            df = pd.DataFrame(classes)
            return float(df["StudentCount"].iloc[0]), float(df["HomeroomTeacher"].iloc[0])
        except Error as e:
            print(f"Error executing FindClass: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def find_class_id_by_name(class_name=None, term=None, year=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindClassByName', [class_name, term, year])
            class_id = None
            for result in cursor.stored_results():
                data = result.fetchall()
                if data:
                    class_id = data[0].get('ClassID')
            return class_id
        except Error as e:
            return f"Error executing FindClassByName: {e}"
        finally:
            cursor.close()
            conn.close()   

    @staticmethod
    def find_class_name_by_id(class_id=None, term=None, year=None):
        conn = Manager.connect_db()
        if not conn:
            return None  # Return None if connection fails

        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindClassByID', [class_id, term, year])
            class_name = None
            for result in cursor.stored_results():
                data = result.fetchall()
                if data:
                    class_name = data[0].get('ClassName')  # Adjust column name if different
            return class_name
        except Error as e:
            return f"Error executing FindClassByName: {e}"
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_class_students(class_id=None, class_name=None, Term=None, Year=None):
        """
        Retrieve a list of students for a specific class.
        
        Args:
            class_id (int): The ClassID of the class to fetch students for.
        
        Returns:
            pandas.DataFrame: DataFrame containing student details (StudentID, StudentName, Address, BirthDate, Email).
        """
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            class_id = int(class_id) if class_id is not None else None
            class_name = str(class_name) if class_name is not None else None
            Term = int(Term) if Term is not None else None
            Year = int(Year) if Year is not None else None

            cursor.callproc('GetClassStudents', [class_id, class_name, Term, Year])
            students = []
            for result in cursor.stored_results():
                students = result.fetchall()
            df = pd.DataFrame(students)
            return df
        except Error as e:
            return(f"Error executing GetClassStudents: {e}")
        finally:
            cursor.close()
            conn.close()
    @staticmethod
    def remove_student_from_class(student_id, class_id, term, year):
        try:
            conn = Manager.connect_db()
            if not conn:
                return None
            cursor = conn.cursor()
            cursor.callproc('RemoveStudentFromClass', [student_id, class_id, term, year])
            return None
        except Error as e:
            print(f"Error: {e}")
            return None
        finally:
            cursor.close()
            conn.close()  
    @staticmethod
    def add_student_with_class(student_id, class_id, term, year):
        try:
            conn = Manager.connect_db()
            if not conn:
                return None
            cursor = conn.cursor()
            cursor.callproc('AddStudentWithClass', [student_id, class_id, term, year])
            for result in cursor.stored_results():
                row = result.fetchone()
                if row:
                    return row[0]  # Trả về NewStudentID
            return None
        except Error as e:
            print(f"Error: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_class_schedule(class_id, class_name, Term, Year):
        """
        Lấy lịch học của một lớp dựa trên ClassID và PerId bằng stored procedure GetClassSchedule.
        
        Parameters:
        - class_id: ID của lớp.
        - per_id (int): ID của kỳ học.
        
        Returns:
        - pandas.DataFrame: DataFrame chứa lịch học với các cột ClassName, TeacherName, SubjectName, 
                            DayOfWeek, StartTime, EndTime, WeekNumber.
        """
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('GetClassSchedule', [class_id, class_name, Term, Year])
            schedules = []
            for result in cursor.stored_results():
                schedules = result.fetchall()
            # Convert list of dictionaries to DataFrame
            df = pd.DataFrame(schedules)
            return df
        except Error as e:
            print(f"Error executing GetClassSchedule: {e}")
            return None
        finally:
            cursor.close()
            conn.close()
    @staticmethod
    def export_to_excel(df, filename="manager_export.xlsx"):
        """
        Export a DataFrame to an Excel file.
        
        Args:
            df (pandas.DataFrame): DataFrame to export.
            filename (str): Name of the output Excel file (default: 'manager_export.xlsx').
        
        Returns:
            str: Path to the generated Excel file, or None if failed.
        """
        try:
            # Create a temporary file path if filename is not absolute
            if not os.path.isabs(filename):
                temp_dir = tempfile.gettempdir()
                file_path = os.path.join(temp_dir, filename)
            else:
                file_path = filename
            
            # Export DataFrame to Excel
            df.to_excel(file_path, index=False, engine='openpyxl')
            return file_path
        except Exception as e:
            print(f"Error exporting to Excel: {e}")
            return None
        
#Student         
    @staticmethod
    def add_student(name, address, birthdate, email):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('AddStudent', [name, address, birthdate, email])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing AddStudent: {e}")
            return None
        finally:
            cursor.close()
            conn.close()





    @staticmethod
    def delete_student(student_id):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('DeleteStudent', [student_id])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            return(f"Error executing DeleteStudent: {e}")
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update_student(student_id, name, address, birthdate, email):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateStudent', [student_id, name, address, birthdate, email])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False           
        except Error as e:
            print(f"Error executing UpdateStudent: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update_student_name(student_id=None, student_name=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateStudentName', [student_id, student_name])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateStudentName: {e}")
            return None
        finally:
            cursor.close()
            conn.close()
    
    @staticmethod
    def update_student_address(student_id=None, student_name=None, address=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateStudentAddress', [student_id, student_name, address])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateStudentAddress: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update_student_birth_date(student_id=None, student_name=None, birth_date=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateStudentBirthDate', [student_id, student_name, birth_date])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateStudentBirthDate: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update_student_email(student_id=None, student_name=None, email=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateStudentEmail', [student_id, student_name, email])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateStudentEmail: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def find_student_detail(student_id=None, student_name=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindStudentDetail', [student_id, student_name])
            for result in cursor.stored_results():
                df = result.fetchall()
            conn.commit()
            return pd.DataFrame(df)
        except Error as e:
            print(f"Error executing FindStudentDetail: {e}")
            return None
        finally:
            cursor.close()
            conn.close()


    @staticmethod
    def find_student_by_name(student_name=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindStudentByName', [student_name])
            student_ids = [row[0] for result in cursor.stored_results() for row in result.fetchall()]
            return student_ids
        except Error as e:
            print(f"Error executing FindStudentByName: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def find_student_by_id(student_id=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindStudentByID', [student_id])
            data = []
            for result in cursor.stored_results():
                data = result.fetchall()
            df1 = pd.DataFrame(data)
            return df1["StudentName"].iloc[0]

        except Error as e:
            print(f"Error executing FindStudentByID: {e}")
            return None
        finally:
            cursor.close()
            conn.close()   

    # @staticmethod
    # def update_student_class(student_id=None, student_name=None, class_id=None, term=None, year=None):
    #     conn = Manager.connect_db()
    #     if not conn:
    #         return pd.DataFrame()
        
    #     try:
    #         cursor = conn.cursor(dictionary=True)
    #         cursor.callproc('UpdateStudentClass', [student_id, student_name, class_id, term, year])
    #         results = []
    #         for result in cursor.stored_results():
    #             affected_rows = result.fetchone()[0]
    #         conn.commit()
    #         return True if affected_rows > 0 else False
    #     except Error as e:
    #         print(f"Error executing UpdateStudentClass: {e}")
    #         return None
    #     finally:
    #         cursor.close()
    #         conn.close()    

#Teacher
    @staticmethod
    def get_all_subjects():
        query = "SELECT SubjectID, SubjectName FROM Subjects"
        df = Manager.fetch_data(query)
        try:
            result = tuple(f"{row['SubjectID']}, {row['SubjectName']}" for _, row in df.iterrows())
            return result
        except Exception as e:
            return(f"Error: {e}")

    @staticmethod
    def add_teacher(name, subject_id, email):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing AddTeacher: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update_teacher(teacher_id, name, subject_id, email):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateTeacher', [teacher_id, name, subject_id, email])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateTeacher: {e}")
            return None
        finally:
            cursor.close()
            conn.close()
    
    @staticmethod
    def update_teacher_name(teacher_id, name):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateTeacherName', [teacher_id, name])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateTeacherName: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update_teacher_subject(teacher_id, name, subject_id):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateTeacherSubject', [teacher_id, name, subject_id])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateTeacherSubject: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update_teacher_email(teacher_id, name, email):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('UpdateTeacherEmail', [teacher_id, name, email])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateTeacherEmail: {e}")
            return None
        finally:
            cursor.close()
            conn.close()           

    @staticmethod
    def delete_teacher(teacher_id):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('DeleteTeacher', [teacher_id])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            return(f"Error executing DeleteTeacher: {e}")
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def find_teacher(teacher_id=None, teacher_name=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindTeacher', [teacher_id, teacher_name])
            for result in cursor.stored_results():
                data = result.fetchall()
            return pd.DataFrame(data)
        except Error as e:
            print(f"Error executing FindTeacher: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def find_teacher_by_name_and_subject(teacher_name = None, subject_id=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindTeacherByNameAndSubject', [teacher_name, subject_id])
            teacher_ids = [row[0] for result in cursor.stored_results() for row in result.fetchall()]
            return teacher_ids
        except Error as e:
            print(f"Error executing FindTeacherByNameAndSubject: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def find_teacher_id_by_name(teacher_name = None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindTeacherByName', [teacher_name])
            data = []
            for result in cursor.stored_results():
                data = result.fetchall()
            df = pd.DataFrame(data)
            return df["TeacherID"].iloc[0]
        except Error as e:
            print(f"Error executing FindTeacherByName: {e}")
            return None
        finally:
            cursor.close()
            conn.close()
    
    @staticmethod
    def find_teacher_name_by_teacher_id(teacher_id=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindTeacherBySTeacherID', [teacher_id])
            data = []
            for result in cursor.stored_results():
                data = result.fetchall()
            df = pd.DataFrame(data)
            return df["TeacherName"].iloc[0]
        except Error as e:
            print(f"Error executing FindTeacherBySubjectName: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    #add find teacher by id return name


    @staticmethod
    def get_all_teachers():
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('GetAllTeachers')
            teacher = []
            for result in cursor.stored_results():
                teacher = result.fetchall()
            df = pd.DataFrame(teacher)
            return df
        except Error as e:
            print(f"Error executing GetAllTeachers: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()


    @staticmethod
    def get_teacher_schedule(teacher_id, term, year):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            teacher_id = int(teacher_id) if teacher_id else None
            term = int(term) if term is not None else None
            year = int(year) if year is not None else None     
            cursor.callproc('GetTeacherSchedule', [teacher_id, term, year])
            teachersch = []
            for result in cursor.stored_results():
                teachersch = result.fetchall()
            df = pd.DataFrame(teachersch)
            return df
        except Error as e:
            print(f"Error executing GetTeacherSchedule: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()
        
#Student
    @staticmethod
    def get_all_student():
        query = "SELECT StudentID, StudentName, Address, BirthDate, Email FROM Students"
        df = Manager.fetch_data(query)
        
        try:
            # Return a list of tuples for each student with proper fields
            result = [(
                row['StudentID'],
                row['StudentName'],
                row['Address'],
                row['BirthDate'],
                row['Email']
            ) for _, row in df.iterrows()]
            return result
        except Exception as e:
            return(f"Error: {e}")
#Grade
    @staticmethod
    def find_grade_by_student(student_id=None, subject_id=None, term=None, year=None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('FindGradeByStudent', [student_id, subject_id, term, year])
            results = []
            for result in cursor.stored_results():
                results = result.fetchall()
            df = pd.DataFrame(results)
            return df
        except Error as e:
            print(f"Error executing FindGradeByStudent: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def update_grade(grade_id = None, score = None, weight = None, term =None, year = None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('Updategrade', [grade_id, score, weight, term, year])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False
        except Error as e:
            print(f"Error executing UpdateGrade: {e}")
            return None
        finally:
            cursor.close()
            conn.close()
    
    @staticmethod
    def add_grade(subject_id = None, student_id = None, score = None, weight = None, term = None, year = None):
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('AddGrade', [subject_id, student_id,  score, weight, term, year])
            for result in cursor.stored_results():
                affected_rows = result.fetchone()[0]
            conn.commit()
            return True if affected_rows > 0 else False    
        except Error as e:
            print(f"Error executing AddGrade: {e}")
            return None
        finally:
            cursor.close()
            conn.close()

#Class
    @staticmethod
    def get_fee_summary_by_period(term: int, year:int) -> pd.DataFrame:
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('sp_fee_summary_by_period', [term, year])
            for result in cursor.stored_results():
                data = result.fetchall()
            return pd.DataFrame(data)
        except Exception as e:
            print(f"Error in get_fee_summary_by_period: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_fee_summary_by_student(student_id: int) -> pd.DataFrame:
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('sp_fee_summary_by_student', [student_id])
            for result in cursor.stored_results():
                data = result.fetchall()
            return pd.DataFrame(data)
        except Exception as e:
            print(f"Error in get_fee_summary_by_student: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_fee_detail_by_student(student_id: int) -> pd.DataFrame:
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('sp_fee_detail_by_student', [student_id])
            for result in cursor.stored_results():
                data = result.fetchall()
            return pd.DataFrame(data)
        except Exception as e:
            print(f"Error in get_fee_detail_by_student: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_fee_by_class_term_year(class_id: int, term: int, year: int) -> pd.DataFrame:
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            class_id = int(class_id) if class_id is not None else None
            term = int(term) if term is not None else None
            year = int(year) if year is not None else None
            cursor.callproc('sp_fee_by_class_term_year', [class_id, term, year])
            for result in cursor.stored_results():
                data = result.fetchall()
            return pd.DataFrame(data)
        except Exception as e:
            print(f"Error in get_fee_by_class_term_year: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def get_fee_total_by_class(class_id: int, term: int, year: int) -> pd.DataFrame:
        conn = Manager.connect_db()
        if not conn:
            return pd.DataFrame()
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.callproc('sp_fee_total_by_class', [class_id, term, year])
            for result in cursor.stored_results():
                data = result.fetchall()
            return pd.DataFrame(data)
        except Exception as e:
            print(f"Error in get_fee_total_by_class: {e}")
            return pd.DataFrame()
        finally:
            cursor.close()
            conn.close()

    @staticmethod
    def export_by_class_to_excel(df: pd.DataFrame, filename="money_by_class.xlsx"):
        try:
            if not os.path.isabs(filename):
                temp_dir = tempfile.gettempdir()
                file_path = os.path.join(temp_dir, filename)
            else:
                file_path = filename

            with pd.ExcelWriter(file_path, engine='openpyxl') as writer:
                for class_name, group_df in df.groupby("ClassName"):
                    safe_name = class_name[:31].replace('/', '-')
                    group_df.to_excel(writer, sheet_name=safe_name, index=False)

            return file_path
        except Exception as e:
            print(f"Error exporting by class to Excel: {e}")
            return None
       
