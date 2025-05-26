import streamlit as st
import base64
import toml
from datetime import datetime
from streamlit_extras.switch_page_button import switch_page
#from Account import User


class Time:
    @staticmethod
    def real_time():
        hour = datetime.now().hour
        return 'morning' if 5 <= hour < 12 else 'afternoon' if 12 <= hour < 18 else 'evening'

class VisualHandler:
    # Convert image to base64 
    @staticmethod
    def get_base64_image(file):
        with open(file, "rb") as f:
            data = f.read()
        return base64.b64encode(data).decode()
    # Set background
    @classmethod
    @st.cache_data
    def set_background(cls):
        # Load background image
        bg_image = cls.get_base64_image("background.jpg")
        st.markdown(
            f"""
            <style>
                 .stApp {{
            background-image:  url("data:image/jpg;base64,{bg_image}");
            background-size: cover;
            background-repeat: no-repeat;
            background-attachment: fixed;
        }}
        </style>
        """,
        unsafe_allow_html=True
        )


    # Custom sidebar
    @classmethod
    def custom_sidebar(cls):
        st.logo('slidebar_logo.png', icon_image = 'main_body_logo.png')
        with st.sidebar:
            if st.button("Home"):
                st.balloons()
                st.switch_page("Home")
            st.divider()
            st.title("User Management")
            #User.user_management()
            if st.session_state == False:
                if st.button("Log In"):
                    st.switch_page(r"pages\Log_in.py")
            else:
                if st.button("Log Out"):
                    st.session_state.log = False
                    st.switch_page(r"pages\Log_in.py")

            st.divider()
            st.markdown('<div style="text-align: center">© 2025 by Group 4 - DSEB 65B</div>', unsafe_allow_html=True)

    @classmethod
    def initial(cls):
        cls.custom_sidebar()
        cls.set_background()
        