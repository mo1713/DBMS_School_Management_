import os
import pandas as pd
import numpy as np
from dotenv import load_dotenv
from sqlalchemy import create_engine, MetaData, Table, text
from sqlalchemy.orm import sessionmaker
from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Table as RLTable, Paragraph, TableStyle, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter
import streamlit as st
class SchoolAnalytics:
    def __init__(self):
        load_dotenv()
        self.DB_USER = os.getenv("DB_USER")
        self.DB_PASS = os.getenv("DB_PASS")
        self.DB_HOST = os.getenv("DB_HOST")
        self.DB_NAME = os.getenv("DB_NAME")

        self.engine = create_engine(f"mysql+mysqlconnector://{self.DB_USER}:{self.DB_PASS}@{self.DB_HOST}/{self.DB_NAME}")
        self.metadata = MetaData()
        self.metadata.reflect(bind=self.engine)
        self.session = sessionmaker(bind=self.engine)()

        self.Grades = Table('Grades', self.metadata, autoload_with=self.engine)
        self.Students = Table('Students', self.metadata, autoload_with=self.engine)
        self.Subjects = Table('Subjects', self.metadata, autoload_with=self.engine)
        self.Teachers = Table('Teachers', self.metadata, autoload_with=self.engine)
        self.Classes = Table('Classes', self.metadata, autoload_with=self.engine)
        self.Classes_Teacher = Table('Classes_Teacher', self.metadata, autoload_with=self.engine)
        self.Class_period = Table('Class_period', self.metadata, autoload_with=self.engine)
        self.Students_Classes = Table('Students_Classes', self.metadata, autoload_with=self.engine)
        self.Schedules = Table('Schedules', self.metadata, autoload_with=self.engine)
        self.Money = Table('Money', self.metadata, autoload_with=self.engine)
        self.Academic_period = Table('Academic_period', self.metadata, autoload_with=self.engine)
        self.StudentLocation = Table('Student_Locations', self.metadata, autoload_with=self.engine)

        self.geolocator = Nominatim(user_agent="my_geocoder", timeout=5)
        self.geocode = RateLimiter(self.geolocator.geocode, min_delay_seconds=1.5, max_retries=3)
    def get_summary_stats(self):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            query = """
                SELECT 
                    (SELECT COUNT(*) FROM Students),
                    (SELECT COUNT(*) FROM Teachers),
                    (SELECT CAST(SUM(Value) AS DECIMAL(15,2)) FROM Money)
            """
            cursor.execute(query)
            result = cursor.fetchone()
            # Optionally convert to float in Python as extra safety
            student_count = result[0]
            teacher_count = result[1]
            total_money = float(result[2]) if result[2] is not None else 0.0
            return student_count, teacher_count, total_money
        except Exception as e:
            print(f"Error in get_summary_stats: {e}")
            return 0, 0, 0.0
        finally:
            cursor.close()
            conn.close()


    def take_class_name(self):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT DISTINCT classname FROM classes")
            result = cursor.fetchall()
            return (row[0] for row in result)  # extract only the class names
        finally:
            cursor.close()
            conn.close()
    def take_term(self):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT DISTINCT Term FROM Academic_period")
            result = cursor.fetchall()
            return (row[0] for row in result)  # extract only the class names
        finally:
            cursor.close()
            conn.close()
    def take_year(self):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT DISTINCT Year FROM Academic_period")
            result = cursor.fetchall()
            return (row[0] for row in result)  # extract only the class names
        finally:
            cursor.close()
            conn.close()
    def take_subject(self):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.execute("SELECT DISTINCT SubjectName FROM Subjects")
            result = cursor.fetchall()
            return (row[0] for row in result)  # extract only the class names
        finally:
            cursor.close()
            conn.close()
    def generate_scorecard(self, student_id: int, term: int = None, year: int = None):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_get_scorecard", [student_id, term, year])
            results = []
            for result in cursor.stored_results():
                rows = result.fetchall()
                col_names = result.column_names
                results.extend(dict(zip(col_names, row)) for row in rows)
        except:
            return ValueError(f"Error generating scorecard for student {student_id}. Please check the input parameters.")
        finally:
            cursor.close()
            conn.close()

        if not results:
            return f"No data found for student {student_id} in the term {term} of the {year}."

        df = pd.DataFrame(results)
        df = df.rename(columns={
            "StudentName": "Student Name",
            "ClassName": "Class Name",
            "SubjectName": "Subject Name",
            "TeacherName": "Teacher Name"
        })

        df['Weighted Score'] = df['Score'] * df['Weight']
        overall_score = df['Weighted Score'].sum() / df['Weight'].sum()

        output_pdf = f"scorecards/scorecard_{student_id}.pdf"
        os.makedirs("scorecards", exist_ok=True)

        doc = SimpleDocTemplate(output_pdf, pagesize=A4)
        styles = getSampleStyleSheet()
        title = f"Scorecard: Student {student_id} - {df['Student Name'].iloc[0]}"
        if term or year:
            title += f"  ({term or ''} / {year or ''})"
        elems = [Paragraph(title, styles['Title'])]
        elems.append(Paragraph(f"<b>CLASS:</b> {df['Class Name'].iloc[0]}", styles['Normal']))

        df = df.drop(columns=["Weight", "Weighted Score"])
        df3 = df["Student Name"].drop_duplicates()
        df = df.drop(columns=["Student Name", "StudentID"])
        df_pdf = df.drop(columns=["Class Name"])
        df2 = df["Class Name"].drop_duplicates()
        table_data = [df_pdf.columns.tolist()] + df_pdf.values.tolist()

        t = RLTable(table_data)
        t.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.lightgrey),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.black),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, -1), 9),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 6),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.grey),
        ]))

        elems.append(t)
        elems.append(Spacer(1, 12))
        elems.append(Paragraph(f"<b>GPA:</b> {overall_score:.2f}", styles['Normal']))
        doc.build(elems)

        return df2.iloc[0], df3.iloc[0], df, float(overall_score)
    

    def generate_class_average_score(self, class_name: str, term: int, year: int):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_get_class_average_score", [class_name, term, year])
            results = []
            for result in cursor.stored_results():
                rows = result.fetchall()
                col_names = result.column_names
                results.extend(dict(zip(col_names, row)) for row in rows)
        finally:
            cursor.close()
            conn.close()

        if not results:
            return f"No data found for class '{class_name}' in term {term} of year {year}."
        df = pd.DataFrame(results)
        return float(results[0]["AverageScore"])

    def top_students_per_class(self, class_name: str, term: int, year: int, top_n: int):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_class_summary", [class_name, term, year, top_n])
            result_sets = cursor.stored_results()

            class_gpa_result = next(result_sets)
            class_gpa_row = class_gpa_result.fetchone()
            class_gpa = class_gpa_row[0] if class_gpa_row else None

            top_students_result = next(result_sets)
            rows = top_students_result.fetchall()
            col_names = top_students_result.column_names
            top_students = [dict(zip(col_names, row)) for row in rows]
        finally:
            cursor.close()
            conn.close()

        if not top_students:
            raise ValueError(f"No data found for class {class_name} in Term {term}, Year {year}.")

        df = pd.DataFrame(top_students).rename(columns={
            "StudentName": "Student Name",
            "ClassName": "Class Name",
            "Term": "Term",
            "Year": "Year",
            "AvgScore": "Average Score"
        })
        return df

    def generate_class_average_per_subjects(self, class_name: str, term: int, year: int):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_class_average_per_subject", [class_name, term, year])
            results = []
            for result in cursor.stored_results():
                rows = result.fetchall()
                col_names = result.column_names
                results.extend(dict(zip(col_names, row)) for row in rows)
        finally:
            cursor.close()
            conn.close()

        if not results:
            return f"No grade data available for class '{class_name}' in term {term} of year {year}."

        df = pd.DataFrame(results).rename(columns={
            "ClassName": "Class Name",
            "Term": "Term",
            "Year": "Year",
            "SubjectName": "Subject Name",
            "SubjectAvg": "Average Score"
        })
        df = df.drop(columns = ["Class Name", "Term", "Year"])
        return df

    def generate_teacher_load(self, term: int, year: int):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_teacher_load", [term, year])
            results = []
            for result in cursor.stored_results():
                rows = result.fetchall()
                col_names = result.column_names
                results.extend(dict(zip(col_names, row)) for row in rows)
        finally:
            cursor.close()
            conn.close()

        if not results:
            return f"No data found for term {term} and year {year}."

        df = pd.DataFrame(results).rename(columns={
            "TeacherID": "Teacher ID",
            "TeacherName": "Teacher Name",
            "SubjectName": "Subject Name",
            "NumClasses": "Number of Classes"
        })

        df.to_excel("teacher_load.xlsx", index=False)
        return df

    def get_students_with_address(self, term, year):
        sql = text("""
        SELECT s.StudentID, s.StudentName, s.Address
        FROM Students s
        JOIN Students_Classes sc ON s.StudentID = sc.StudentID
        JOIN Class_period cl ON sc.Class_perID = cl.id
        JOIN Classes c ON cl.ClassID = c.ClassID
        JOIN Academic_period ap ON cl.PerId = ap.PerId
        WHERE s.Address IS NOT NULL AND s.Address <> ''
        AND ap.Term = :term AND ap.Year = :year
    """)
        with self.engine.connect() as conn:
            result = conn.execute(sql, {"term": term, "year": year})
            return pd.DataFrame(result.fetchall(), columns=result.keys())

    def get_student_locations_df(self, term : int, year : int):
        df = self.get_students_with_address(term, year)
        print(f"Total {len(df)} students with address")

        geo_results = []
        for _, row in df.iterrows():
            student_id = row['StudentID']
            name = row['StudentName']
            address = row['Address']
            try:
                location = self.geocode(address)
                if location:
                    geo_results.append({
                    "StudentID": student_id,
                    "Student Name": name,
                    "Address": address,
                    "Latitude": location.latitude,
                    "Longitude": location.longitude
                })
                else:
                    print(f"Not found coordinate for: {address}")
            except Exception as e:
                return(f"Error geocoding '{address}': {e}")
        df = pd.DataFrame(geo_results)
        df = df.drop(columns=["StudentID", "Student Name", "Address"])
        df = df.rename(columns={
            "Latitude": "latitude",
            "Longitude": "longitude"
        })
        return df

    def top_students_overall(self, term: int, year: int, top_n: int):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_top_students_overall", [term, year, top_n])
            result = next(cursor.stored_results())
            rows = result.fetchall()
            col_names = result.column_names
            top_students = [dict(zip(col_names, row)) for row in rows]
        finally:
            cursor.close()
            conn.close()

        if not top_students:
            raise ValueError(f"No data found for Term {term}, Year {year}.")

        return pd.DataFrame(top_students).rename(columns={
        "StudentName": "Student Name",
        "ClassName": "Class Name",
        "AverageScore": "Average Score"
    })


    def top_students_per_subject(self, term: int, year: int, top_n: int, subject_name: str = None):
        conn = self.engine.raw_connection()
        try:
            cursor = conn.cursor()
            cursor.callproc("sp_top_students_per_subject", [term, year, top_n, subject_name])
            result_sets = cursor.stored_results()
            result = next(result_sets)                  # Lấy result đầu tiên
            rows = result.fetchall()                     # Lấy dữ liệu
            col_names = result.column_names              # Lấy tên cột từ result
            students = [dict(zip(col_names, row)) for row in rows]
        finally:
            cursor.close()
            conn.close()

        if not students:
            raise ValueError(f"No data found for Term {term}, Year {year}, Subject {subject_name}.")

        return pd.DataFrame(students).rename(columns={
            "SubjectName": "Subject",
            "StudentName": "Student Name",
            "AverageScore": "Average Score"
        })