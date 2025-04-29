import sys
import os

# Adjust import path to use custom loremipsum.
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

import loremipsum
sentence = loremipsum.sentence(max_char=20)
open("dist/sentence.txt", "w").write(sentence)

