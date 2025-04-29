import sys
import os

# Adjust import path to use custom loremipsum.
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import loremipsum
paragraph = loremipsum.paragraph(max_char=100)
open("dist/paragraph.txt", "w").write(paragraph)

