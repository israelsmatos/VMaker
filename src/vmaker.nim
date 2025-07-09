# Esse arquivo implementa um CLI para VMaker
from backend import create_project, work, version, input
from os import commandLineParams
from std/parseopt import initOptParser, cmdEnd, cmdShortOption, cmdLongOption, next
import strformat

const
  help = fmt"""
VMaker {version}
=================

Uma pequena ferramenta CLI para compilação de vídeos usando FFmpeg.

USO:
  vmaker -s[:nome_do_projeto]
  vmaker -i[:nocleanup]
  vmaker -fps:valor -ratio:valor -scale:valor
  vmaker -h

OPÇÕES:
  -s                Cria um novo projeto na pasta padrão de vídeos.
  -s:nome_do_projeto  Especifica o nome do projeto.
  -i                Inicia a compilação dos vídeos no projeto atual.
  -i:nocleanup      Mantém arquivos temporários após a compilação.
  -fps:valor        Define os quadros por segundo (padrão: 30).
  -ratio:valor      Define a proporção do vídeo (padrão: 16/9).
  -scale:valor      Define a resolução do vídeo (padrão: 1920:1080).
  -h                Exibe esta mensagem de ajuda.
"""

proc isNilOrEmpty(s: string): bool =
  s.isNil or s.len == 0


proc main() =
  # Inicializa os valores padrão
  var
    preprosessed: bool = false
    ratio: string = "16/9"
    scale: string = "1920:1080"
    fps: string = "30"
    nocleanup: bool = false
    pname: string

  # Verifica se não há argumentos fornecidos
  if commandLineParams().len == 0:
    echo help
    quit(0)

  # Processa os argumentos fornecidos
  var p = initOptParser(commandLineParams())
  while true:
    p.next()
    case p.kind
    of cmdEnd:
      break
    of cmdShortOption, cmdLongOption:
      case p.key
      of "s":
        if p.val != "":
          create_project(p.val)
        else:
          pname = input("Entre o nome do projeto: ")
          create_project(pname)
        quit(0)
      
      of "i":
        if p.val == "nocleanup":
          nocleanup = true
      
      of "fps":
        fps = p.val

      of "ratio":
        ratio = p.val

      of "scale":
        scale = p.val

      of "h":
        echo help
        quit(0)
      
      else:
        echo "Opção inválida: ", p.key
        echo help
        quit(1)
    else:
      echo "Argumento inesperado: ", p.val
      echo help
      quit(1)

  # Valida e ajusta os parâmetros
  if fps notin ["24", "30", "60"]:
    echo "FPS inválido. Usando padrão: 30."
    fps = "30"

  if ratio.isNilOrEmpty():
    ratio = "16/9"

  if scale.isNilOrEmpty():
    scale = "1920:1080"

  # Executa o trabalho principal
  try:
    echo fmt"Iniciando com as configurações: ratio={ratio}, scale={scale}, fps={fps}"
    work(preprosessed=preprosessed, ratio=ratio, scale=scale, fps=fps, nocleanup=nocleanup)
  except Exception as e:
    echo "Erro durante a execução: ", e.msg
    quit(1)

when isMainModule:
  main()
