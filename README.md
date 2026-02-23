# MEGA PDF Editor – webová aplikace (iPhone)

Tahle verze je **web app**, kterou spustíš hned v prohlížeči (Safari na iPhonu).

## Co umí
- přihlášení do MEGA (email + heslo)
- načtení PDF souborů z root složky účtu
- otevření PDF v browseru (aktuálně strana 1)
- **vkládání textu kliknutím/tapnutím do PDF**
- **kreslení prstem** (overlay) a zapsání kresby do PDF
- **náhradu existujících textů** na 1. straně (najít/nahradit, pokud text umí PDF.js vyčíst)
- nahrání upravené verze zpět do MEGA

## Rychlé spuštění
```bash
npm install
npm start
```
Pak otevři:
- lokálně: `http://localhost:3000`
- na iPhonu: `http://<IP_tveho_pocitace>:3000`

## Poznámky
- Přihlašování do MEGA běží na backendu (`server.js`) přes balíček `megajs`.
- Aplikace zatím pracuje s PDF soubory v rootu MEGA účtu.
- Upravený soubor nahrává s příponou `-edited.pdf`.
- Náhrada textu je praktická varianta: původní text se překryje bílým obdélníkem a vykreslí se nový text na stejné pozici.
