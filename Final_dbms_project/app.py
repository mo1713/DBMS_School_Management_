import streamlit as st
# from Account import User
from Modules import VisualHandler
from streamlit_extras.switch_page_button import switch_page

# User.create_user_table() # check if database is created

VisualHandler.initial() # create session_state

# main function
def main():
    print(st.session_state)
    st.balloons()
    if 'log' not in st.session_state:
        st.session_state.log = False
    st.switch_page("pages/1_Home.py")
if __name__ == "__main__":
    main()