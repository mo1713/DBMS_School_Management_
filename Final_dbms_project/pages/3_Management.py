import streamlit as st
from streamlit_extras.switch_page_button import switch_page
from Modules import VisualHandler
import base64

st.set_page_config(
    page_title="Home",
    page_icon="🏠",
    layout="wide",

    initial_sidebar_state="collapsed",
) # config page, called only once


VisualHandler.initial() # custom sidebar, custom background...

def display_home(): 
    col1, col2= st.columns([0.5,0.5])
    with col1: 
            st.markdown("""
            <style>
            .main-text {
                font-size: 64px;
                font-weight: bold;
                color: navy;
                line-height: 1.2;
            }
            </style>
            """, unsafe_allow_html=True)
            st.markdown(
            "<h1 style='color: navy;'>SUDY</h1>",
                unsafe_allow_html=True
            )
            st.divider()
            st.markdown("<div class='main-text'>The User-friendly<br>Platform For<br> Academic Staff Users</div>", unsafe_allow_html = True)
            st.divider()
            st.markdown("<p style='font-size:24px; color:navy;'>The Best Platform Manage Your School</p>",unsafe_allow_html=True)
            st.write("School Management System build by group 4 of DSEB 65B")
            colu1, colu2 = st.columns([0.2,0.8])
            with colu1:
                if st.button('Log In', key = 'login'):
                    st.switch_page('pages/4_Log_in.py')
            # with colu2:
            #     if st.button('Sign up'):
                    # st.switch_page('pages\Log_in.py')
    with col2:
            st.image('hpage.png',use_container_width= True) # render image into page
   

display_home()