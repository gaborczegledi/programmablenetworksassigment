# Programozható Hálózatok projektmunka
## Feladat
A feladat egy P4-es "Adblocker" elkészítése, azaz webcím alapú szűrés P4 kóddal. Az elképzelés, hogy szimulálunk egy csomagküldés, amely során a csomagban elhelyezünk egy DNS webcímet és a P4 (kód alapján felkonfigurált switch) eldobja a csomagot, amennyiben egy bizonyos webcímmel egyezést talál.
## Felhasznált eszközök
- Mininet, BMv2
- Python
- Órai virtuális gép Linux alapú rendszerrel, a fentiekkel felkonfigurálva
## Ötlet a megoldás implementálásához
Tekintettel arra, hogy a P4 nem ad lehetőséget külső fájlokból való beolvasásra, így a konstans értékkel történő hasonlítás marad opciónak. Ezáltal, a feladat leegyszerűsödik egyetlen webcímmel való összevetésre. A P4DNS projektből ihletett merítve (https://github.com/cucl-srg/P4DNS) elkészíthető a P4 DNS-sel kibővített header-je, amely az egyes id-kon felül rendelkezik egy questionname attribútummal, erre történhet a match-elés. Természetesen, saját tábla is kell ehhez az Ingress-szakaszban, illetve mintaillesztés a webcímre. A szimulációhoz egy egyszerű Python scriptet kell összeírni, amellyel létrehozunk két klienst, majd az egyikről a másik felé, egy switchen keresztül, küldünk egy csomagot, így a switch-ben dől el, hogy továbbításra kerül-e a csomag vagy eldobódik. Az automatizált futtatást egy .sh script biztosítja.
## Problémák
- A csomag elküldésre kerül, de nincsen semmi arra utaló jel, hogy eldobódna a csomag. Az órai mintafeladatok Python scriptjei is ezt a metódust használták, így ezért ebből indultunk ki.
- A P4Tutorials (https://github.com/p4lang/tutorials/tree/master) feladataihoz tartozó és a P4DNS-hez írt Python és .sh scriptek túl összetettek, így nehezen tudtuk leszűrni a szimuláció menetét, más, számunkra releváns forrást pedig nem tudtunk találni, ami támpontot adhatott volna a feladat megoldásához.
- A DNS-es header-ek egyedüliként ezen a komplex P4DNS projekten kerültek felhasználásra, de a projekt nem DNS-szűrőként funkcionál, így lehet, hogy más funkcionalitást is át kellett volna onnan emelni, amiről nekünk nem volt ismeretünk.
- A feladat megoldásához kapcsolódó absztrakt szakirodalom bő, de a programozási nyelv felhasználása nem annyira elterjedt, hogy a feladat megvalósításához sok támpontot kaphassunk hasonló mintapéldákon keresztül.
