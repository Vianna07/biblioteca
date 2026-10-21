#!/usr/bin/env python3
"""
gerar_documento.py -- Gera o PDF do 4 bimestre com resultados REAIS.

1. Recria o banco rodando scripts/4bim/00..04 no container MySQL.
2. Executa os blocos de teste (05..09) numa unica sessao, como o
   Workbench faz, e captura cada resultado ou erro.
3. Preenche documento.html e imprime o PDF com o Chromium.

ATENCAO: o banco "biblioteca" do container e apagado e recriado.

Uso (com o container do compose.yaml no ar):
    pip install pymysql
    python3 docs/4bim/gerar_documento.py

Variaveis opcionais: MYSQL_CONTAINER (mysql_lib), MYSQL_HOST
(127.0.0.1), MYSQL_PORT (3306), MYSQL_PASSWORD (lida do container).
"""
import datetime
import decimal
import html
import os
import re
import subprocess
import sys
from pathlib import Path

import pymysql

RAIZ = Path(__file__).resolve().parents[2]
SCRIPTS = RAIZ / "scripts" / "4bim"
DOCS = Path(__file__).resolve().parent
CONTAINER = os.environ.get("MYSQL_CONTAINER", "mysql_lib")
HOST = os.environ.get("MYSQL_HOST", "127.0.0.1")
PORT = int(os.environ.get("MYSQL_PORT", "3306"))

SETUP = ["00_base.sql", "01_estrutura.sql", "02_procedures.sql",
         "03_cursor.sql", "04_triggers.sql"]
TESTES = ["05_teste_procedures.sql", "06_teste_cursor.sql",
          "07_teste_triggers.sql", "08_rotina_completa.sql",
          "09_demonstracao.sql"]

SQL_KEYWORDS = """
ADD AFTER ALTER AND AS BEFORE BEGIN BETWEEN BOOLEAN BY CALL CASE CHAR CLOSE
COLUMN CONCAT CONTINUE COUNT CREATE CURSOR DATE DECIMAL DECLARE DEFAULT DELETE
DELIMITER DESC DESCRIBE DROP EACH ELSE ELSEIF END ENUM EXISTS FETCH FOR FROM
GROUP HANDLER IF IN INOUT INSERT INT INTERVAL INTO IS JOIN KEY LEAVE LIMIT LOOP
MESSAGE_TEXT NOT NULL ON OPEN OR ORDER OUT PRIMARY PROCEDURE ROW SELECT SET
SHOW SIGNAL SQLSTATE STATUS TABLE TEMPORARY THEN TRIGGER TRIGGERS UPDATE USE
VALUES VARCHAR WHEN WHERE AUTO_INCREMENT DATETIME FOUND TRUE FALSE LEFT
""".split()


def senha():
    if "MYSQL_PASSWORD" in os.environ:
        return os.environ["MYSQL_PASSWORD"]
    return subprocess.check_output(
        ["docker", "exec", CONTAINER, "printenv", "MYSQL_ROOT_PASSWORD"],
        text=True).strip()


def recriar_banco(pwd):
    for nome in SETUP:
        print(f"[setup] {nome}")
        with open(SCRIPTS / nome, "rb") as f:
            subprocess.run(
                ["docker", "exec", "-i", CONTAINER, "mysql", "-uroot", f"-p{pwd}",
                 "--default-character-set=utf8mb4"],
                stdin=f, check=True, stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL)


def ler_blocos(nome):
    """Divide um arquivo de teste em blocos marcados com '-- >> ID | titulo'."""
    blocos, atual = [], None
    for linha in (SCRIPTS / nome).read_text(encoding="utf-8").splitlines():
        m = re.match(r"--\s*>>\s*(\S+)\s*\|\s*(.+)", linha)
        if m:
            atual = {"id": m.group(1), "titulo": m.group(2).strip(), "linhas": []}
            blocos.append(atual)
        elif atual is not None:
            if linha.startswith("-- ====="):
                atual = None
            else:
                atual["linhas"].append(linha)
    for b in blocos:
        texto = "\n".join(b["linhas"]).strip()
        b["sql"] = texto
        sem_comentario = "\n".join(l for l in texto.splitlines()
                                   if not l.strip().startswith("--"))
        b["comandos"] = [c.strip() for c in re.split(r";\s*(?:\n|$)", sem_comentario)
                         if c.strip()]
    return blocos


def executar(conn, comando):
    """Executa um comando e devolve a lista de saidas no estilo Workbench."""
    saidas = []
    cur = conn.cursor()
    try:
        afetadas = cur.execute(comando)
        while True:
            if cur.description:
                cols = [d[0] for d in cur.description]
                saidas.append({"tipo": "grade", "cols": cols, "linhas": cur.fetchall()})
            if not cur.nextset():
                break
        verbo = comando.split()[0].upper()
        if not saidas and verbo == "CALL":
            saidas.append({"tipo": "ok", "msg": "executado com sucesso"})
        elif not saidas and verbo in ("INSERT", "UPDATE", "DELETE"):
            saidas.append({"tipo": "ok", "msg": f"{afetadas} linha(s) afetada(s)"})
    except pymysql.err.MySQLError as e:
        codigo, msg = e.args[0], e.args[1] if len(e.args) > 1 else ""
        saidas.append({"tipo": "erro", "msg": f"Error Code: {codigo}. {msg}"})
    finally:
        cur.close()
    return saidas


def fmt(v):
    if v is None:
        return '<span class="null">NULL</span>'
    if isinstance(v, (datetime.datetime,)):
        return v.strftime("%Y-%m-%d %H:%M:%S")
    if isinstance(v, bytes):
        v = v.decode("utf-8", "replace")
    if isinstance(v, decimal.Decimal):
        return str(v)
    return html.escape(str(v))


def destacar_sql(sql):
    tokens = re.compile(r"(--[^\n]*)|('(?:[^'])*')|(@\w+)|(\b[A-Za-z_]+\b)|(\$\$)")
    saida, pos = [], 0
    for m in tokens.finditer(sql):
        saida.append(html.escape(sql[pos:m.start()]))
        t = m.group(0)
        if m.group(1):
            saida.append(f'<span class="c">{html.escape(t)}</span>')
        elif m.group(2):
            saida.append(f'<span class="s">{html.escape(t)}</span>')
        elif m.group(3):
            saida.append(f'<span class="v">{html.escape(t)}</span>')
        elif m.group(4) and t.upper() in SQL_KEYWORDS and t.isupper():
            saida.append(f'<span class="k">{t}</span>')
        else:
            saida.append(html.escape(t))
        pos = m.end()
    saida.append(html.escape(sql[pos:]))
    return "".join(saida)


def render_bloco(bloco, resultados, colunas=None):
    partes = [f'<div class="bloco"><div class="bloco-tit"><span class="tag">{bloco["id"]}</span>'
              f'{html.escape(bloco["titulo"])}</div>',
              f'<pre class="sql">{destacar_sql(bloco["sql"])}</pre>']
    for comando, saidas in resultados:
        for s in saidas:
            if s["tipo"] == "erro":
                partes.append(f'<div class="out erro"><span class="ico">&#10007;</span>'
                              f'{html.escape(s["msg"])}</div>')
            elif s["tipo"] == "ok":
                verbo = comando.split()[0].upper()
                partes.append(f'<div class="out ok"><span class="ico">&#10003;</span>'
                              f'{verbo}: {s["msg"]}</div>')
            else:
                cols = s["cols"]
                idx = list(range(len(cols)))
                if colunas:
                    idx = [i for i, c in enumerate(cols) if c in colunas]
                cab = "".join(f"<th>{html.escape(cols[i])}</th>" for i in idx)
                corpo = "".join(
                    "<tr>" + "".join(
                        f'<td class="longo">{fmt(l[i])}</td>' if len(str(l[i])) > 28
                        else f"<td>{fmt(l[i])}</td>" for i in idx) + "</tr>"
                    for l in s["linhas"])
                if not s["linhas"]:
                    corpo = f'<tr><td colspan="{len(idx)}" class="vazio">(nenhuma linha)</td></tr>'
                partes.append(f'<div class="grade"><table><thead><tr>{cab}</tr></thead>'
                              f'<tbody>{corpo}</tbody></table>'
                              f'<div class="rodape">{len(s["linhas"])} linha(s)</div></div>')
    partes.append("</div>")
    return "\n".join(partes)


def extrair_objeto(nome):
    """Codigo de CREATE PROCEDURE/TRIGGER/TABLE <nome> a partir dos scripts."""
    for arq in ["01_estrutura.sql", "02_procedures.sql", "03_cursor.sql", "04_triggers.sql"]:
        texto = (SCRIPTS / arq).read_text(encoding="utf-8")
        m = re.search(rf"CREATE (?:PROCEDURE|TRIGGER) {nome}\b.*?END\$\$", texto, re.S)
        if not m:
            m = re.search(rf"CREATE TABLE {nome}\b.*?\);", texto, re.S)
        if not m:
            m = re.search(rf"ALTER TABLE {nome}\b.*?;", texto, re.S)
        if m:
            return f'<pre class="sql codigo">{destacar_sql(m.group(0))}</pre>'
    raise SystemExit(f"Objeto nao encontrado nos scripts: {nome}")


def montar_entrega():
    """Junta 01..09 em um unico script, como pede o item 12 do enunciado."""
    partes = ["-- ================================================================\n"
              "-- Projeto: Biblioteca Digital\n"
              "-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida\n"
              "-- Script do 4 bimestre: tabela de log, procedures, cursor,\n"
              "-- triggers e comandos de teste. Pre-requisito: 00_base.sql.\n"
              "-- Gerado por docs/4bim/gerar_documento.py a partir de 01..09.\n"
              "-- ================================================================\n"]
    for nome in SETUP[1:] + TESTES:
        partes.append(f"\n\n-- ################################################################\n"
                      f"-- {nome}\n"
                      f"-- ################################################################\n\n")
        partes.append((SCRIPTS / nome).read_text(encoding="utf-8"))
    (SCRIPTS / "entrega_4bim.sql").write_text("".join(partes), encoding="utf-8")


def montar_instalacao():
    """Junta 00..04 em um script que roda inteiro no Workbench, sem erros."""
    partes = ["-- ================================================================\n"
              "-- Projeto: Biblioteca Digital\n"
              "-- Integrantes: Gustavo Vianna, Gabriel Cardoso, Rafael de Almeida\n"
              "-- INSTALACAO COMPLETA: recria o banco do zero e cria tabela de log,\n"
              "-- procedures, cursor e triggers. Nao tem testes, entao roda inteiro\n"
              "-- com o botao do raio (Ctrl+Shift+Enter). Conecte como root.\n"
              "-- Depois rode os testes (05..09) bloco a bloco.\n"
              "-- Gerado por docs/4bim/gerar_documento.py a partir de 00..04.\n"
              "-- ================================================================\n"]
    for nome in SETUP:
        partes.append(f"\n\n-- ################################################################\n"
                      f"-- {nome}\n"
                      f"-- ################################################################\n\n")
        partes.append((SCRIPTS / nome).read_text(encoding="utf-8"))
    (SCRIPTS / "instalar_tudo.sql").write_text("".join(partes), encoding="utf-8")


def main():
    montar_entrega()
    montar_instalacao()
    pwd = senha()
    recriar_banco(pwd)

    conn = pymysql.connect(host=HOST, port=PORT, user="root", password=pwd,
                           database="biblioteca", charset="utf8mb4", autocommit=True)
    executar(conn, "SET SQL_SAFE_UPDATES = 0")
    blocos = {}
    for nome in TESTES:
        print(f"[testes] {nome}")
        for b in ler_blocos(nome):
            b["resultados"] = [(c, executar(conn, c)) for c in b["comandos"]]
            blocos[b["id"]] = b
    conn.close()

    modelo = (DOCS / "documento.html").read_text(encoding="utf-8")

    def sub_run(m):
        bid, opts = m.group(1), m.group(2) or ""
        if bid not in blocos:
            raise SystemExit(f"Bloco de teste inexistente: {bid}")
        cm = re.search(r"cols=([\w,]+)", opts)
        return render_bloco(blocos[bid], blocos[bid]["resultados"],
                            cm.group(1).split(",") if cm else None)

    saida = re.sub(r"<!--RUN:([\w-]+)(\s[^>]*)?-->", sub_run, modelo)
    saida = re.sub(r"<!--CODE:(\w+)-->", lambda m: extrair_objeto(m.group(1)), saida)

    faltando = set(blocos) - set(re.findall(r"<!--RUN:([\w-]+?)(?:\s[^>]*)?-->", modelo))
    if faltando:
        print(f"[aviso] blocos de teste nao usados no documento: {sorted(faltando)}")

    html_out = DOCS / "documento_gerado.html"
    pdf_out = DOCS / "Biblioteca_4bim_Procedures_Cursores_Triggers.pdf"
    html_out.write_text(saida, encoding="utf-8")
    subprocess.run(["chromium", "--headless", "--no-sandbox", "--disable-gpu",
                    "--no-pdf-header-footer", f"--print-to-pdf={pdf_out}",
                    html_out.as_uri()], check=True,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"[ok] {pdf_out}")


if __name__ == "__main__":
    sys.exit(main())
