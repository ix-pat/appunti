from pathlib import Path
import re

files = [
    "00-intro.Rmd", "01-dati.Rmd", "02-distr-freq.Rmd", "03-media-varianza.Rmd",
    "04-mediana-percentili.Rmd", "05-Probabilita.Rmd", "06-Variabili-Casuali.Rmd",
    "07-vc-importanti.Rmd", "08-tlc.Rmd", "09-Statistiche-Campionarie.Rmd",
    "10-Inferenza.Rmd", "11-Stima.Rmd", "12-Verosimiglianza.Rmd",
    "13-stima-intervallare.Rmd", "14-test-intro.Rmd", "15-test-mu-pi.Rmd",
    "16-test-2C.Rmd", "17-regressione-I.Rmd", "18-regressione-II.Rmd",
    "19-chi-quadro.Rmd", "23-APPENDICE.Rmd", "24-Libro.Rmd", "25-test-functions.Rmd"
]

# regex per la riga iniziale: ::: {.definition name="Frequenze Assolute"}
inner_start = re.compile(r'^:::\{\.(definition|proposition|theorem)\s*(name="([^"]+)")?\}$')
inner_end = re.compile(r'^:::$')

tipo_ita = {
    "definition": "Definizione",
    "proposition": "Proposizione",
    "theorem": "Teorema"
}

estratti = []

for filename in files:
    path = Path(filename)
    if not path.exists():
        continue
    with path.open(encoding="utf-8") as f:
        inside_block = False
        block_lines = []
        for line in f:
            stripped = line.strip()
            if not inside_block:
                if stripped.startswith(":::") and ".info" in stripped:
                    inside_block = True
                    block_lines = []
            else:
                if stripped == ":::":  # fine blocco
                    if block_lines:
                        lines = [l.strip() for l in block_lines if l.strip()]
                        match = inner_start.match(lines[0])
                        if match and inner_end.match(lines[-1]):
                            tipo_en = match.group(1)
                            tipo = tipo_ita[tipo_en]
                            nome = match.group(3)
                            testo = " ".join(lines[1:-1]).strip()
                            if nome:
                                estratti.append(f"**{tipo}** ({nome}) {testo}")
                            else:
                                estratti.append(f"**{tipo}** {testo}")
                        else:
                            contenuto = "\n".join(block_lines).strip()
                            estratti.append(f"<!-- {filename} -->\n{contenuto}")
                    inside_block = False
                    block_lines = []
                else:
                    block_lines.append(line.rstrip())

# Salvataggio
Path("estratti-info.Rmd").write_text("\n\n".join(estratti), encoding="utf-8")
print("[✓] Estrazione completata e formattata correttamente.")
##########################################################################


infile = Path("estratti-info.Rmd")
outfile = Path("estratti-info2.Rmd")

tipo_ita = {
    "definition": "Definizione",
    "proposition": "Proposizione",
    "theorem": "Teorema"
}

# Inizio blocco: ::: {.definition name="..."} o simili
start_pat = re.compile(r'^:::\{\.(definition|proposition|theorem)(?:\s+name="([^"]*)")?\}$', re.IGNORECASE)
# Nuova fine blocco: riga che inizia con commento <!--
comment_pat = re.compile(r'^<!--')

lines = infile.read_text(encoding="utf-8").splitlines()
out_lines = []
inside = False
tipo = ""
nome = ""
contenuto = []
contatore_blocchi = 0

for idx, line in enumerate(lines):
    stripped = line.strip()

    if not inside:
        match = start_pat.match(stripped)
        if match:
            tipo_raw = match.group(1).lower()
            tipo = tipo_ita.get(tipo_raw, tipo_raw.capitalize())
            nome = match.group(2) or ""
            contenuto = []
            inside = True
        else:
            out_lines.append(line)

    else:
        if comment_pat.match(stripped):  # fine blocco trovata via commento
            testo = "\n".join(contenuto).strip()
            if nome:
                out_lines.append(f"**{tipo}** ({nome})\n{testo}")
            else:
                out_lines.append(f"**{tipo}**\n{testo}")
            out_lines.append("")  # riga vuota
            out_lines.append("---------------")
            out_lines.append("")  # riga vuota
            inside = False
            tipo = ""
            nome = ""
            contatore_blocchi += 1
            out_lines.append(line)  # mantieni il commento
        else:
            contenuto.append(line.rstrip())

# chiusura blocco finale non terminato con commento
if inside and contenuto:
    testo = "\n".join(contenuto).strip()
    if nome:
        out_lines.append(f"**{tipo}** ({nome})\n{testo}")
    else:
        out_lines.append(f"**{tipo}**\n{testo}")
    out_lines.append("")
    out_lines.append("---------------")
    out_lines.append("")
    contatore_blocchi += 1

# scrittura su file
outfile.write_text("\n".join(out_lines), encoding="utf-8")
print(f"[✓] Conversione completata. Trovati e trasformati {contatore_blocchi} blocchi.")
print(f"📄 Salvato in '{outfile.name}'")
