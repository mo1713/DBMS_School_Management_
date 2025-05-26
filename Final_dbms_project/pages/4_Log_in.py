
import streamlit as st
from Modules import VisualHandler
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError
VisualHandler.initial() 
import streamlit as st

# Dummy user credentials
def login_user(username, password):
    DB_HOST = "localhost"
    DB_PORT = "3306"
    DB_NAME = "school_management"

    try:
        engine = create_engine(f"mysql+mysqlconnector://{username}:{password}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
        with engine.connect() as conn:
            role_mapping = {
                "student": "Student",
                "homeroom_teacher": "Homeroom Teacher",
                "subject_teacher": "Subject Teacher",
                "academic_coordinator": "Vice Principal",
                "admin_user": "Principal"
            }
            return role_mapping.get(username, "Admin")
    except SQLAlchemyError:
        return None

def display_login():
    if st.session_state.log == False:
        st.title("🔐 Login")

        st.subheader("Please enter your credentials:")

        username = st.text_input("Username")
        password = st.text_input("Password", type="password")

        role = login_user(username, password)
        if st.button("Login"):
            if role:
                st.session_state.log = True
                with open(".env", "w") as env_file:
                    env_file.write(f"DB_USER={username}\n")
                    env_file.write(f"DB_PASS={password}\n")
                    env_file.write(f"DB_HOST=localhost\n")
                    env_file.write(f"DB_NAME=school_management")
                st.session_state["username"] = username
                st.session_state["role"] = role
                st.success(f"Welcome, {username} as {role}!")
                st.switch_page("pages/2_Dashboard.py")
            else:
                st.error("Invalid username or password.")
    else:
        st.switch_page("pages/2_Dashboard.py")
display_login()
