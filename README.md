# vlang-urlshortener

Encurtador de URLs minimalista escrito em V (veb + vredis) com front-end simples em `index.html`.

Este README guia você desde a instalação das dependências até executar e testar a aplicação localmente.

## Visão geral

- Backend: V (veb) — endpoints:
  - `GET /shorten?url=<URL>` — retorna JSON com `shortened_url` ou `error`.
  - `GET /:short_id` — redireciona para a URL original.
- Persistência: Redis (chave = short_id, valor = JSON com original+short).
- Front-end: `index.html` (UI responsiva). Há também `requests.http` com exemplos.

## Pré-requisitos

- V (compilador) instalado — siga as instruções oficiais: https://vlang.io/
- Redis (local) acessível em `localhost:6379` — pode ser instalado localmente ou via Docker.
- (Opcional) Docker, se preferir rodar Redis em um container.

### Instalar V

Siga a documentação oficial para sua plataforma: https://vlang.io/

No WSL / Linux o processo básico é (exemplo):

```bash
# instalar V via script oficial (ver docs atualizados em vlang.io)
curl -sSL https://get.vlang.io | bash
source ~/.bashrc
v version
```

No Windows, siga as instruções da página oficial (pode usar WSL para mais facilidade).

### Rodando Redis (opções)

1. Usando Docker (recomendado se você não tem Redis instalado):

```powershell
# PowerShell / WSL
docker run -p 6379:6379 -d --name urlshortener-redis redis
```

2. Instalando nativamente

- Windows: instale o Redis via WSL ou use um pacote compatível. Consulte https://redis.io/docs/getting-started/installation/

Verifique se o Redis está ativo:

```bash
# exemplo: usar redis-cli (se disponível)
redis-cli ping
# resposta esperada: PONG
```

## Executando o projeto

1. Clone o repositório (se ainda não o fez):

```bash
git clone https://github.com/dacmarcell/vlang-urlshortener.git
cd vlang-urlshortener
```

2. Certifique-se de que o Redis está rodando (veja seção anterior).

3. Execute a aplicação V:

```powershell
# No WSL / Linux
v run main.v

# No Windows (PowerShell) — se o v estiver no PATH
v run main.v
```

Por padrão o servidor escuta em `http://localhost:8000` (conforme `main.v`).

4. Abra a interface web

- Abra no navegador: http://localhost:8000/
- O front-end (`index.html`) também está no repositório e é servido pela rota `/` do veb.

## Testando os endpoints

Exemplos com `requests.http` (incluído no repo) ou via curl/PowerShell:

```http
GET http://localhost:8000/shorten?url=https://example.com
```

Exemplo com curl (WSL / Linux):

```bash
curl "http://localhost:8000/shorten?url=https://example.com"
# Exemplo de resposta JSON:
# {"shortened_url":"http://localhost:8000/Ab3xYz","error":""}
```

No PowerShell, use Invoke-RestMethod:

```powershell
Invoke-RestMethod -Uri "http://localhost:8000/shorten?url=https://example.com"
```

Para testar o redirecionamento, abra a URL retornada no navegador (ou faça GET na rota curta, ex. `/Ab3xYz`).

## Configurações importantes

- O domínio base usado nas respostas é definido em `main.v` na struct `App` (propriedade `domain`). Por padrão:

```v
domain: 'http://localhost:8000/'
```

Se você executar em outro host/porta, atualize `main.v` ou ajuste o campo `domain` antes de compilar.

## Possíveis problemas e soluções

- Erro de conexão com o Redis: verifique se o Redis está rodando em `127.0.0.1:6379` ou ajuste o host/porta no `main.v`.
- CORS / Acesso a `index.html` local: abra a UI via o servidor (`http://localhost:8000`) para evitar problemas de CORS quando a integração JS estiver ativa.
- Porta 8000 ocupada: pare o serviço que usa a porta ou altere a porta no `veb.run[...]` em `main.v`.

## Build para produção

Compile o binário (exemplo):

```bash
v -prod -o urlshortener.exe main.v   # Windows/PowerShell
# ou
v -prod -o urlshortener main.v       # Linux/WSL

# Execute o binário:
./urlshortener   # Linux
.\urlshortener.exe  # Windows
```

## Estrutura do repositório

- `main.v` — servidor V, endpoints e integração com Redis.
- `index.html` — front-end com estilos; versões anteriores continham lógica JS para integração.
- `requests.http` — exemplos de requisições para testar endpoints.
- `README.md` — este arquivo.

## Contribuição

Contribuições são bem-vindas:

- Abra uma issue para discutir mudanças ou problemas.
- Envie PRs com mudanças pequenas e documentadas.

## Licença

Indique aqui a licença do projeto (se houver). Se quiser, posso adicionar uma `LICENSE` (ex.: MIT).

---

Se quiser, eu posso:

- adicionar um `docker-compose.yml` para subir Redis + app em containers, ou
- incluir instruções para CI (ex.: GitHub Actions) que buildem e testem a aplicação.
  Url Shortener

user give an long url, system retrieves short url
response model: domain.com/1234
1234 is an id which indicates an long url

"persistence": redis
