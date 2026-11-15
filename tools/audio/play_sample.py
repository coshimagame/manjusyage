import sys
import time
import winsound

def play(path, sec=8):
    print(f"Playing sample of {path} for {sec} seconds...")
    winsound.PlaySound(path, winsound.SND_FILENAME | winsound.SND_ASYNC)
    time.sleep(sec)
    winsound.PlaySound(None, winsound.SND_PURGE)
    print("Done.")

if __name__ == "__main__":
    p = sys.argv[1] if len(sys.argv) > 1 else r"assets\audio\music\bgm_stage02_plan_a.wav"
    s = int(sys.argv[2]) if len(sys.argv) > 2 else 8
    play(p, s)
