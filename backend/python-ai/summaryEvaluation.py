# -*- coding: utf-8 -*-
"""Video Understanding and Summary Evaluation.ipynb

Automatically generated by Colab.

Original file is located at
    https://colab.research.google.com/drive/1f4rl_ZXciuAz2N_JHJRh5IdpWS5mtYX_

# 🎬 Video Understanding & Summary Evaluation AI

This project lets a user watch a video and write a one-line summary.  
The AI will compare their answer to the correct one and give feedback on their understanding using a similarity score.
"""

!pip install sentence-transformers

from sentence_transformers import SentenceTransformer, util
from IPython.display import YouTubeVideo
import ipywidgets as widgets
from IPython.display import display

model = SentenceTransformer('all-MiniLM-L6-v2')

from IPython.display import display, YouTubeVideo
import ipywidgets as widgets

button = widgets.Button(description="Show Video 🎬")
output = widgets.Output()

def on_button_clicked(b):
    with output:
        display(YouTubeVideo('dQw4w9WgXcQ', width=640, height=360))

button.on_click(on_button_clicked)
display(button, output)

# This is the ideal answer for the video
ideal_summary = "The video explains how plants make their food using sunlight through photosynthesis."

def evaluate_summary(user_summary, ideal_summary):
    embedding_ideal = model.encode(ideal_summary, convert_to_tensor=True)
    embedding_user = model.encode(user_summary, convert_to_tensor=True)
    score = util.pytorch_cos_sim(embedding_user, embedding_ideal).item()
    print("Similarity Score:", round(score, 2))

    if score < 0.5:
        return "❌ You haven't understood the video properly. Please try again."
    elif score == 0.5:
        return "⚠️ Hmm... It's okay. Please re-watch the video."
    elif score > 0.75:
        return "✅ Great job! You understood the video well."
    else:
        return "👍 You're getting there. Almost a good summary!"

# Text box for the user to type their summary
summary_box = widgets.Text(
    value='',
    placeholder='Type your one-line summary here...',
    description='Summary:',
    disabled=False,
    layout=widgets.Layout(width='80%')
)

# Button to submit
submit_button = widgets.Button(description="Submit")

# Output area to display feedback
output = widgets.Output()

# Define what happens when the button is clicked
def on_submit(b):
    with output:
        output.clear_output()
        result = evaluate_summary(summary_box.value, ideal_summary)
        print(result)

# Link the button click to the function
submit_button.on_click(on_submit)

# Show everything on the page
display(summary_box, submit_button, output)