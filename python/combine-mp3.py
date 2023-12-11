# adds 1 second silence between files. needs ffmpeg
# choco install ffmpeg
from pydub import AudioSegment
import os

# Get all MP3 files in the current directory
mp3_files = [file for file in os.listdir() if file.endswith('.mp3')]

# Create an empty AudioSegment object to store combined audio
combined = AudioSegment.empty()

# Combine all MP3 files with a 1-second silence gap
for idx, file in enumerate(mp3_files):
    audio = AudioSegment.from_mp3(file)
    combined += audio

    # Add 1 second of silence after each file (except the last one)
    if idx != len(mp3_files) - 1:
        # Generate 1 second of silence
        silence_segment = AudioSegment.silent(duration=1000)  # 1000 milliseconds = 1 second
        combined += silence_segment

# Export the combined audio to a single MP3 file
combined.export("combined_with_silence.mp3", format="mp3")
