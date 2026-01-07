# Proiect-ASC

##Descriere

Acest proiect face parte din cursul Arhitectura Sistemelor de Calcul (ASC) și este implementat în limbajul assembly. Scopul proiectului este de a demonstra abilitățile de programare la nivel scăzut, înțelegerea modului de funcționare al procesorului și a construcțiilor de cod la nivel de mașină.

##Proiectul include:
-cod sursă în Assembly (*.asm),
-documentație detaliată a implementării,
-diagramă reprezentând arhitectura / fluxul de execuție,
-și un fișier README.md pentru navigare rapidă.

## Structura repository-ului

- Proiect-ASC/
  - README.md
  - main.asm
  - brigitte.asm
  - diana.asm
  - documentatie.pdf
  - diagrama.pdf

##Fișiere cheie
-main.asm – Implementarea principală a programului.
-brigitte.asm, diana.asm – Procedurile implementate individual.
-documentatie.pdf – Documentația proiectului (descrierea cerințelor, designul).
-diagrama.pdf – Diagramă vizuală a arhitecturii sau pașilor logici ai programului.

## Cerințele proiectului
Proiectul trebuie să îndeplinească următoarele cerințe:

- **Citirea unui șir de octeți în hexazecimal**  
  Utilizatorul introduce un șir de octeți în format hex, care va fi prelucrat de program.

- **Conversia octeților în binar**  
  Fiecare octet din șir trebuie convertit în reprezentarea sa binară.

- **Construirea unui cuvânt `C`**  
  Pe baza octeților din șir se construiește un cuvânt `C`.

- **Sortarea descrescătoare a șirului**  
  Octeții din șir trebuie ordonați de la cel mai mare la cel mai mic.

- **Determinarea octetului cu cel mai mare număr de biți 1 (>3)**  
  Programul identifică octetul care are cei mai mulți biți setați la 1 și afișează și poziția acestuia în șir.

- **Manipularea șirului prin rotirea octeților**  
  Programul rotește octeții din șir folosind un număr `N` calculat anterior.

##Despre Assembly
Codul este scris în Assembly, un limbaj de programare de nivel scăzut, care permite control direct asupra instrucțiunilor procesorului. Pentru mai multe informații despre Assembly și modul de execuție a codului sursă, consultă cursurile sau resursele de referință pe arhitectura procesorului pentru care este scris codul.

## Cum se compilează și rulează
Acest proiect folosește **TASM** și **TLINK** pentru compilare și rulare.

### Modul principal: `main.asm`

- **Descriere:** Modulul principal al programului.
- **Pași de compilare și rulare:**

```bash
tasm main.asm        # Compilează codul Assembly în obiect
tlink /v main.obj    # Leagă obiectul pentru a crea fișierul executabil
td main.exe          # Rulează programul
```

##Contribuții
Acest repository este un proiect de curs. Realizat de echipa DBB, din studentele Mranovatz Brigitte, Diana Persa si Bianca Nodis.

Licență
Proiectul este furnizat fără licență explicită (sau adaugă licența pe care o preferi cum ar fi MIT, GPL etc.).
