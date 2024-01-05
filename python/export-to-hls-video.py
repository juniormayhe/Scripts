#python ..\hls.py input.mp4 output-folder
import subprocess
import sys
import os

def execute_command(command):
    subprocess.run(command, shell=True, check=True)

def encrypt_and_rename_init(output_folder):
    path = os.path.join(output_folder, 'video', 'avc1')
    print(f"changing to path {path}...")
    os.chdir(path)
    execute_command('mp4encrypt --method MPEG-CENC --key 1:a0a1a2a3a4a5a6a7a8a9aaabacadaeaf:b0b1b2b3b4b5b6b7b8b9babbbcbdbebf init.mp4 init-enc.mp4')
    
    os.remove('init.mp4')
    os.rename('init-enc.mp4', 'init.mp4')
    
    execute_command(f"mp4info init.mp4")

def main():
    if len(sys.argv) != 3:
        print("Usage: hls.py input.mp4 output-folder")
        sys.exit(1)

    input_file = sys.argv[1]
    output_folder = sys.argv[2]

    print("fragmenting...")
    execute_command(f"mp4fragment {input_file} temp.mp4")

    print("exporting to hls...")
    execute_command(f"mp4dash ./temp.mp4 -o {output_folder} -f --hls")
    
    #execute_command(f"mp4dash ./temp.mp4 -o {output_folder} -f --hls --encryption-cenc-scheme=cbcs --encryption-key=audio:a0a1a2a3a4a5a6a7a8a9aaabacadaeaf:b0b1b2b3b4b5b6b7b8b9babbbcbdbebf,video:a0a1a2a3a4a5a6a7a8a9aaabacadaeaf:b0b1b2b3b4b5b6b7b8b9babbbcbdbebf")
    
    os.remove('temp.mp4')
    #print("encrypting...")
    #encrypt_and_rename_init(output_folder)
    path = os.path.join(output_folder, 'video', 'avc1','init.mp4')
    execute_command(f"mp4info {path}")
    os.chdir("../../../")
    print("Done!")
    

if __name__ == "__main__":
    main()
    input("Press Enter to exit...")

# https://www.bok.net/Bento4/binaries/Bento4-SDK-1-6-0-641.x86_64-microsoft-win32.zip
# mp4fragment .\desert.mp4 temp.mp4
# mp4dash .\temp.mp4 -o desert -f --hls
# cd .\desert\video\avc1
# mp4encrypt --method MPEG-CENC --key 1:a0a1a2a3a4a5a6a7a8a9aaabacadaeaf:b0b1b2b3b4b5b6b7b8b9babbbcbdbebf init.mp4 init-enc.mp4
# rm init.mp4
# move .\init-enc.mp4 init.mp4 
