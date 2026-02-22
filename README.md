# Mega PDF Editor pro iPad (iOS)

Ukázková SwiftUI aplikace pro iPad, která:
1. Přihlásí uživatele do cloudového úložiště **MEGA**.
2. Načte seznam PDF souborů z účtu.
3. Stáhne vybraný PDF dokument do lokálního sandboxu.
4. Otevře PDF přes `PDFKit` a umožní jednoduché úpravy (zvýraznění a textová poznámka).
5. Uloží upravený PDF soubor zpět do MEGA.

## Co je připraveno
- Architektura `MVVM`.
- Integrace na `MEGASdk` přes servisní vrstvu.
- `PDFKit` editor zabalený do SwiftUI (`UIViewRepresentable`).
- Ukázka workflow „vyber soubor → edituj → nahraj zpět“.

## Co je potřeba doplnit v Xcode
1. Vytvoř iOS App projekt (SwiftUI) pro iPadOS 16+.
2. Přidej soubory ze složky `Sources/`.
3. Přidej SPM dependency na MEGA SDK (podle aktuálního oficiálního repozitáře MEGA).
4. Do `MegaAuthService` doplň bezpečné načítání přihlašovacích údajů (Keychain / OAuth tok).
5. Zapni správné capabilities dle požadavků projektu (např. iCloud jen pokud budeš používat export/import přes Files).

## Doporučení pro produkci
- Nepoužívej hardcoded credentials.
- Přidej šifrování lokálních dočasných souborů.
- Přidej audit log změn PDF.
- Doplněj nástroje pro anotace: kreslení perem (`PencilKit`), razítka, podpis.

## Poznámka
MEGA SDK API se může lišit podle verze. Tady je implementace držena jednoduše a čitelně, aby šla snadno přizpůsobit konkrétní verzi SDK.
