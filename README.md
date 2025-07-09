> # VIDEOMAKER

Foi escrito na linguagem de programação Nim. A ideia foi concebida em 23/01/2023.

## USO
Para iniciar um projeto, use o a opção -s.

### Exemplo:

    $ vmaker -s
    Entre o nome do seu projeto: <Insira o nome aqui>

Pode-se também utilizar uma forma mais rapida de inicialização:
    
    $ vmaker -s:projeto1

### Execução de compilação:
    $ vmaker -i
    Trabalhando no projeto em: C:\Users\Seu Nome\Videos\projeto1

> O CLI providencia um arquivo .ps1(para Powershell) ou .sh(para linux ou mac) com esse comando visando uma maior produtividade já que só basta executa-lo. O resto da operação é automatizado.

## Configuração
O vmaker quando executado pela primeira vez, cria uma pasta chamada "VMaker" no diretorio do Usuário. Dentro desta pasta contém um arquivo de configuração que pode ser modificado. Porém o programa apenas suporta 2 opções:

    WORKING_DIR
        O local padrão onde o programa criará os projetos. 
        Por padrão ele sempre utilizará a pasta "Videos" 
        no diretorio do usuario.

    OUTPUT_FILE 
        O nome do arquivo final a ser gerado após uma 
        compilação de video. Por padrão é "output.mp4".


## Dependências:
- > Ele precisa do FFmpeg pra funcionar. É necessário que esteja instalado no computador.
- > (Opcional) Se for fazer sua própria compilação, o compilador Nim vai precisar estar instalado. Você pode baixa-lo em nim-lang.org

## Compilação própria
Se a instalação de Nim no seu computador estiver OK, modifique o codigo-fonte contido na pasta "src" e execute o comando "nimble build" a partir de um terminal dentro da pasta onde estiver o arquivo "videomaker.nimble", a compilação ocorrerá automaticamente.

## Contato
Telegram: @lolzaws