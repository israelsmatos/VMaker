import os, strutils, strformat

const
    DEF_OUT: string           = "output"
    DEF_INP: string           = "videos"
    DEF_CACHE_AUDIOS: string  = "cache_audio"
    DEF_CACHE_VIDEOS: string  = "cache_video"
    DEF_NORMALI_CACHE: string = "normalized_videos" 
    DEF_FILE_VIDEOS: string   = "videos.txt"
    DEF_FILE_AUDIOS: string   = "audios.txt"
    DEF_CONFIG_FILE: string   = "vmaker.conf"
    DEF_INFO_FILE: string     = "readme.md"
    ONLY_VIDEO: string        = "video_noaudio.mp4"
    ONLY_AUDIO: string        = "output.mp3"
    DEF_CONF_DIR: string      = getHomeDir() / "VMaker"
    DEF_LOG_FILE: string      = DEF_CONF_DIR / "vmaker.log"
    NOTIFICATION_SOUND        = DEF_CONF_DIR / "assets" / "file.wav"
    instructions: string      = "Adicione clipes de vídeo ou vídeos inteiros dentro da pasta 'videos', quando estiver satisfeito, execute o arquivo 'initialise' a partir de um terminal e deixe o resto com o programa."
    version*: string          = "0.1.017022023AR"


var
    CONC_BOTH: string    = "ffmpeg -i $# -i $# -y -codec:a copy -codec:v copy $#" # "ffmpeg -f concat -safe 0 -i $# -i $# -acodec aac -vcodec h264 -f mp4 $#"
    main_dir: string     = getHomeDir() / "Videos"
    output_file: string  = "output.mp4"
    SEPARATOR: string
    clear_cmd: string
    exec_file: string
    video_location: string


let
    SEP_AUDIO: string  = "ffmpeg -i $# -vn -ac 2 -f mp3 $#"
    SEP_VIDEO: string  = "ffmpeg -i $# -map 0 -map -0:a -f mp4 $#"
    CONC_AUDIO: string = "ffmpeg -f concat -safe 0 -i audios.txt $#"
    CONC_VIDEO: string = "ffmpeg -f concat -safe 0 -i videos.txt $#"


when defined(Windows):
    SEPARATOR = "\\"
    exec_file = "initialise.ps1"
    clear_cmd = "cls"

when defined(Linux) or defined(MacOsX):
    SEPARATOR = "/"
    exec_file = "initialise.sh"
    clear_cmd = "clear"


# utilities
proc input*(message: string = ""): string =
    stdout.write(message)
    var inp = stdin.readLine()
    return inp

proc parse_path*(dir_file: string = "", currDir: string = getCurrentDir(), sep: string = SEPARATOR, absolute: bool = false): string =
    if absolute:
        return currDir & sep & dir_file.replace("-", sep)
    else:
        return "." & sep & dir_file.replace("-", sep)


# proc play_audio*(audio_path: string = NOTIFICATION_SOUND) =
#     var player = newPlayer()
#     player.open(audio_path)
#     player.play()
#     player.close()


# Check if the config file exists and update variables
proc check_config(config_file: string = DEF_CONFIG_FILE) =
    var new_config_content = fmt"WORKING_DIR={main_dir}{'\n'}OUTPUT_FILE={output_file}"
    
    if not dirExists(DEF_CONF_DIR):
        createDir(DEF_CONF_DIR)
        var config_file = open(DEF_CONF_DIR / config_file, fmWrite)
        config_file.write(new_config_content)
        config_file.close()
    
    else:
        var read_config = open(DEF_CONF_DIR / config_file, fmRead)
        echo "Arquivo de configuração encontrado!"
        for line in read_config.readAll().split("\n"):
            let data = line.split("=")
            var
                option = data[0]
                value  = data[1]
            
            if option == "WORKING_DIR":
                echo fmt"Diretório principal: {value}"
                main_dir = value
            
            if option == "OUTPUT_FILE":
                echo fmt"Padrão de nome de arquivo gerado: {value}"
                output_file = value

        read_config.close()


proc create_project*(name: string) =
    try:
        check_config()
        
        var dir = main_dir / name
        createDir(dir)
        createDir(dir / DEF_INP)
        
        var file = open(dir / DEF_INFO_FILE, fmWrite)
        file.write(fmt"# Nome do projeto: {name}{'\n'}## Versão do CLI: {version}{'\n'}## Usando FFmpeg no backend{'\n'}{'\n'}- {instructions}")
        file.close()
        
        var exec = open(dir / exec_file, fmWrite)
        exec.write("vmaker -i -fps:60 -ratio:16/9 -scale:720:480")
        exec.close()
        
        echo "Projeto criado com sucesso! Instruções estão dentro da pasta do projeto no arquivo 'readme.md'."
        echo fmt"Local do projeto é {dir}"
        quit(0)
    except OsError:
        echo "Ocorreu um erro do tipo OsError e não foi possível criar o projeto. Esse tipo de erro pode ter haver com a opção WORKING_DIR no arquivo de configuração."
        quit(0)


proc normalize_video*(video_path: string, video_codec: string="libx264", audio_codec: string="aac", audio_bitrate: string="192k", fps: string="30", ratio: string="16/9", scale: string="1920:1080") =
    var filter_complex_spec = "[0:v:0]scale=$#,setdar=$#,fps=$#[v0]" % [scale, ratio, fps]
    var cmd = "ffmpeg -i $# -filter_complex '$#' -map '[v0]' -map 0:a -c:v $# -preset fast -c:a $# -b:a $# $#"
    var output = "$#" % [DEF_NORMALI_CACHE / video_path.split('/')[1]]
    discard execShellCmd(cmd % [video_path, filter_complex_spec, video_codec, audio_codec, audio_bitrate, output])
    echo "Video normalized..."


proc check_dir*( 
    path: string = DEF_INP, 
    preprosessed: bool = false,
    video_codec: string="libx264",
    audio_codec: string="aac", 
    audio_bitrate: string="192k", 
    fps: string,
    ratio: string,
    scale: string
    ) =

    discard execShellCmd("echo '-----COMPILATION LOGS-----\n\n-----BEGIN-----\n\n'")
    echo fmt"Trabalhando no projeto em: {parse_path(absolute=true)}"
    check_config()

    createDir(DEF_CACHE_AUDIOS)
    createDir(DEF_CACHE_VIDEOS)
    createDir(DEF_NORMALI_CACHE)
    createDir(DEF_OUT)
    var p: string
    var n: int
    var audio_txt  = open(DEF_FILE_AUDIOS, fmWrite)
    var video_txt  = open(DEF_FILE_VIDEOS, fmWrite)
        
    if not preprosessed:
        for _, video in walkDir( parse_path(path) ):
            normalize_video(video, video_codec=video_codec, audio_codec=audio_codec, audio_bitrate=audio_bitrate, fps=fps, ratio=ratio, scale=scale)
        discard execShellCmd(fmt"{clear_cmd} && echo 'Normalization done. Compiling...'")


    for _, video in walkDir( parse_path(DEF_NORMALI_CACHE) ):
        p = DEF_CACHE_AUDIOS / fmt"audio[{n}].mp3"
        discard execShellCmd(SEP_AUDIO % [video, p])
        audio_txt.write("file '" & p & "'" & "\n")
    
        p = DEF_CACHE_VIDEOS / fmt"video[{n}].mp4"
        discard execShellCmd(SEP_VIDEO % [video, p])
        video_txt.write("file '" & p & "'" & "\n")

        n += 1
    
    audio_txt.close()
    video_txt.close()


proc add_all* =
    var video = DEF_OUT / ONLY_VIDEO
    var audio = DEF_OUT / ONLY_AUDIO
    discard execShellCmd(CONC_AUDIO % [audio])
    discard execShellCmd(CONC_VIDEO % [video])
    discard execShellCmd(CONC_BOTH % [video, audio, output_file])
    video_location = getCurrentDir() / output_file
    discard execShellCmd("echo '\n\n-----END-----\n\n'")


proc clean_up* =
    discard execShellCmd(clear_cmd)
    echo fmt"Terminando tudo. o video pode ser localizado em {video_location}"
    removeDir(DEF_OUT)
    removeDir(DEF_CACHE_AUDIOS)
    removeDir(DEF_CACHE_VIDEOS)
    removeDir(DEF_NORMALI_CACHE)
    removeFile(DEF_FILE_VIDEOS)
    removeFile(DEF_FILE_AUDIOS)


proc work*(
    preprosessed: bool,
    scale: string,
    fps: string,
    ratio: string,
    path: string = DEF_INP, 
    nocleanup: bool = false
    ) =

    if dirExists(path):
        check_dir(preprosessed=preprosessed, ratio=ratio, scale=scale, fps=fps)
        if nocleanup == true:
            clean_up()
    
    else:
        echo "Não há diretorio para trabalhar. Você está mesmo em uma pasta de projeto?"
        quit(0)
