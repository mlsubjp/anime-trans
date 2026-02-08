#!/usr/bin/env bash
set -e

AUDIO_REPO="$1"     # owner/repo
RELEASE_TAG="$2"    # release tag
AUDIO_FILE="$3"     # audio filename
OUTPUT_NAME="$4"

MODEL_PATH=".cache/models/ggml-kotoba-whisper-v2.0-q5_0.bin"
WHISPER_BIN=".cache/whisper/whisper.cpp/build/bin/whisper-cli"

echo "Downloading audio from $AUDIO_REPO@$RELEASE_TAG"
gh release download "$RELEASE_TAG" -R "$AUDIO_REPO" -p "$AUDIO_FILE" --clobber

echo "Normalizing audio"
ffmpeg -y -i "$AUDIO_FILE" -ar 16000 -ac 1 -c:a pcm_s16le input16.wav

echo "Running Kotoba-Whisper"
"$WHISPER_BIN" \
  -m "$MODEL_PATH" \
  -f input16.wav \
  -l ja \
  -osrt \
  -t "$(nproc)" \
  --beam-size 1 \
  --best-of 1

mv input16.wav.srt "${OUTPUT_NAME}.srt"

echo "Cleaning local audio"
rm -f "$AUDIO_FILE" input16.wav

# echo "Deleting remote release"
# gh release delete "$RELEASE_TAG" -R "$AUDIO_REPO" -y
