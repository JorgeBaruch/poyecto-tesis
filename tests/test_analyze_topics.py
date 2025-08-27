import pytest
import sys
import os

# Add the 'tools' directory to the Python path to allow importing the script
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'tools')))

from analyze_topics import preprocess_text

def test_preprocess_text_basic():
    """
    Tests basic preprocessing functionality: lowercase, punctuation, and stopword removal.
    """
    input_text = "Este es un texto de prueba, con [[p=1]] y números 123. El propósito es verificar."
    expected_output = "texto prueba propósito verificar"
    actual_output = preprocess_text(input_text)
    assert actual_output == expected_output

def test_preprocess_text_empty_string():
    """
    Tests that an empty string input results in an empty string output.
    """
    input_text = ""
    expected_output = ""
    actual_output = preprocess_text(input_text)
    assert actual_output == expected_output

def test_preprocess_text_with_hyphens():
    """
    Tests that hyphens are preserved.
    """
    input_text = "Un concepto teórico-práctico."
    expected_output = "concepto teórico-práctico"
    actual_output = preprocess_text(input_text)
    assert actual_output == expected_output
