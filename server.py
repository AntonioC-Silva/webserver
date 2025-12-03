import os
import json
from http.server import SimpleHTTPRequestHandler, HTTPServer
from urllib.parse import parse_qs
import mysql.connector
from decimal import Decimal

def json_converter(o):
    if isinstance(o, Decimal):
        return float(o)

def conectar_banco():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="senai",
        database="webserver"
    )

def listar_filmes_banco():
    conexao = conectar_banco()
    cursor = conexao.cursor(dictionary=True)
    cursor.execute("SELECT * FROM filme;")
    rows = cursor.fetchall()
    cursor.close()
    conexao.close()
    return rows

def buscar_nome_por_id(tabela, coluna_id, id_valor):
    conexao = conectar_banco()
    cursor = conexao.cursor()
    colunas = {
        "ator": "nome",
        "diretor": "nome",
        "linguagem": "idioma",
        "genero": "tipo",
        "produtora": "nome"
    }
    coluna_nome = colunas.get(tabela, "nome")
    cursor.execute(f"SELECT {coluna_nome} FROM {tabela} WHERE {coluna_id} = %s", (id_valor,))
    resultado = cursor.fetchone()
    cursor.close()
    conexao.close()
    return resultado[0] if resultado else ""

def verificar_filme_existe(titulo):
    conexao = conectar_banco()
    cursor = conexao.cursor()
    sql = "SELECT count(*) FROM filme WHERE titulo = %s"
    cursor.execute(sql, (titulo,))
    resultado = cursor.fetchone()
    cursor.close()
    conexao.close()
    return resultado[0] > 0

def inserir_filme_banco(filme):
    conexao = conectar_banco()
    cursor = conexao.cursor()
    sql = """
        INSERT INTO filme (titulo, ano, diretor, genero, produtora, atores, sinopse)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
    """
    valores = (
        filme.get("nome", ""),
        filme.get("ano", ""),
        filme.get("diretor", ""),
        filme.get("genero", ""),
        filme.get("produtora", ""),
        filme.get("atores", ""),
        filme.get("sinopse", "")
    )
    cursor.execute(sql, valores)
    conexao.commit()
    cursor.close()
    conexao.close()

    
caminho_base = os.path.dirname(os.path.abspath(__file__))
arquivo_json = os.path.join(caminho_base, "filmes.json")

def carregar_filmes():
    if os.path.exists(arquivo_json):
        with open(arquivo_json, "r", encoding="utf-8") as f:
            try:
                return json.load(f)
            except json.JSONDecodeError:
                return []
    return []

def salvar_filmes(filmes):
    with open(arquivo_json, "w", encoding="utf-8") as f:
        json.dump(filmes, f, ensure_ascii=False, indent=4)

class MyHandle(SimpleHTTPRequestHandler):
    def indexx(self, caminho_req):
        try:
            with open(os.path.join(caminho_req, 'index.html'), 'r', encoding='utf-8') as f:
                self.send_response(200)
                self.send_header("Content-type", "text/html")
                self.end_headers()
                self.wfile.write(f.read().encode('utf-8'))
                return None
        except FileNotFoundError:
            pass
        return super().indexx(caminho_req)

    def loadFilme(self):
        rows = listar_filmes_banco()
        filmes_db = []
        for r in rows:
            filmes_db.append({
                "nome": r.get("titulo", ""),
                "ano": str(r.get("ano") or ""),
                "diretor": r.get("diretor") or buscar_nome_por_id("diretor", "id_diretor", r.get("id_diretor")),
                "genero": r.get("genero") or buscar_nome_por_id("genero", "id_genero", r.get("id_genero")),
                "produtora": r.get("produtora") or buscar_nome_por_id("produtora", "id_produtora", r.get("id_produtora")),
                "atores": r.get("atores") or buscar_nome_por_id("ator", "id_ator", r.get("id_ator")),
                "sinopse": r.get("sinopse", "")
            })
        salvar_filmes(filmes_db)
        return filmes_db


    def login(self, usuario, senha):
        usuario_valido = "antonio"
        senha_valida = 12345
        if usuario == usuario_valido and senha == senha_valida:
            return "Usuário Logado"
        else:
            return "Usuário ou senha inválidos"

    def do_GET(self):
        if self.path == "/login":
            self.servir_html("login.html")
        elif self.path == "/cadastro":
            self.servir_html("cadastro.html")
        elif self.path == "/ListarFilmes":
            self.loadFilme()
            self.servir_html("ListarFilmes.html")
        else:
            super().do_GET()

    def servir_html(self, nome_arquivo):
        try:
            with open(os.path.join(os.getcwd(), nome_arquivo), 'r', encoding='utf-8') as f:
                conteudo = f.read()
            self.send_response(200)
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.end_headers()
            self.wfile.write(conteudo.encode('utf-8'))
        except FileNotFoundError:
            self.send_error(404, f"Arquivo não encontrado: {nome_arquivo}")

    def do_POST(self):
        if self.path == '/login':
            tamanho_conteudo = int(self.headers['Content-Length'])
            corpo = self.rfile.read(tamanho_conteudo).decode('utf-8')
            dados_formulario = parse_qs(corpo)
            usuario = dados_formulario.get('Usuario', [""])[0]
            senha_str = dados_formulario.get('senha', ["0"])[0]
            try:
                senha = int(senha_str)
            except ValueError:
                senha = 0
            status_login = self.login(usuario, senha)
            if status_login == "Usuário Logado":
                self.send_response(302)
                self.send_header('Location', '/cadastro')
                self.end_headers()
            else:
                self.send_response(401)
                self.send_header("Content-type", "text/html; charset=utf-8")
                self.end_headers()
                self.wfile.write(status_login.encode('utf-8'))
        elif self.path == '/cadastro':
            tamanho = int(self.headers['Content-Length'])
            dados = parse_qs(self.rfile.read(tamanho).decode('utf-8'))

            nome = dados.get('nome', [""])[0].strip()
            ano = dados.get('ano', [""])[0].strip()
            
            if not nome or not ano.isdigit() or len(ano) != 4:
                self.send_response(400)
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"mensagem": "Erro: Nome é obrigatório e Ano deve ser com pelo menos (4 dígitos)."}).encode('utf-8'))
                return

            if verificar_filme_existe(nome):
                self.send_response(409) 
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"mensagem": f"O filme '{nome}' já existe!"}).encode('utf-8'))
                return

            novo_filme = {
                "nome": nome,
                "ano": ano,
                "atores": dados.get('atores', [""])[0].strip(),
                "diretor": dados.get('diretor', [""])[0].strip(),
                "genero": dados.get('genero', [""])[0].strip(),
                "produtora": dados.get('produtora', [""])[0].strip(),
                "sinopse": dados.get('sinopse', [""])[0].strip()
            }

            try:
                inserir_filme_banco(novo_filme)
                
                filmes = carregar_filmes()
                filmes.append(novo_filme)
                salvar_filmes(filmes)

                self.send_response(201) 
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"mensagem": "Filme cadastrado com sucesso!"}).encode('utf-8'))
            
            except Exception as e:
                print(f"Erro: {e}")
                self.send_response(500) 
                self.send_header("Content-type", "application/json")
                self.end_headers()
                self.wfile.write(json.dumps({"mensagem": "Erro interno ao salvar."}).encode('utf-8'))

        elif self.path == '/delete':
            tamanho_conteudo = int(self.headers['Content-Length'])
            corpo = self.rfile.read(tamanho_conteudo).decode('utf-8')
            dados_formulario = parse_qs(corpo)
            indice = int(dados_formulario.get('index', [-1])[0])
            filmes = carregar_filmes()
            if 0 <= indice < len(filmes):
                removido = filmes.pop(indice)
                salvar_filmes(filmes)
                resposta = f"Filme '{removido.get('nome', 'N/A')}' deletado com sucesso!"
            else:
                resposta = "Filme não encontrado."
            self.send_response(200)
            self.send_header("Content-type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(resposta.encode('utf-8'))
        elif self.path == '/edit':
            tamanho_conteudo = int(self.headers['Content-Length'])
            corpo = self.rfile.read(tamanho_conteudo).decode('utf-8')
            dados_formulario = parse_qs(corpo)
            indice = int(dados_formulario.get('index', [-1])[0])
            filmes = carregar_filmes()
            if 0 <= indice < len(filmes):
                filmes[indice] = {
                    "nome": dados_formulario.get('nome', [""])[0],
                    "atores": dados_formulario.get('atores', [""])[0],
                    "diretor": dados_formulario.get('diretor', [""])[0],
                    "ano": dados_formulario.get('ano', [""])[0],
                    "genero": dados_formulario.get('genero', [""])[0],
                    "produtora": dados_formulario.get('produtora', [""])[0],
                    "sinopse": dados_formulario.get('sinopse', [""])[0]
                }
                salvar_filmes(filmes)
                resposta = "Filme editado com sucesso!"
            else:
                resposta = "Filme não encontrado."
            self.send_response(200)
            self.send_header("Content-type", "text/plain; charset=utf-8")
            self.end_headers()
            self.wfile.write(resposta.encode('utf-8'))
        else:
            super().do_POST()

def main():
    endereco_servidor = ('', 8000)
    httpd = HTTPServer(endereco_servidor, MyHandle)
    print("Servidor rodando em http://localhost:8000")
    httpd.serve_forever()

if __name__ == "__main__":
    main()
