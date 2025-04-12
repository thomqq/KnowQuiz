# Dokument wymagań produktu (PRD) - KnowQuiz

## 1. Przegląd produktu
KnowQuiz to aplikacja webowa wspierająca efektywną naukę poprzez system fiszek generowanych przy pomocy sztucznej inteligencji. Aplikacja umożliwia tworzenie tematów i lekcji, automatyczne generowanie treści fiszek na podstawie wprowadzonych pytań, a następnie naukę z wykorzystaniem algorytmu uwzględniającego historię powtórek. Produkt wykorzystuje OpenAI API zarówno do generowania odpowiedzi na pytania tworzone przez użytkownika, jak i do oceny poprawności odpowiedzi udzielanych podczas nauki.

## 2. Problem użytkownika
Efektywna nauka wymaga systematycznego powtarzania materiału, jednak tradycyjne tworzenie fiszek jest czasochłonne i wymaga dużego nakładu pracy. Użytkownicy potrzebują narzędzia, które:
- Przyspieszy proces tworzenia fiszek dzięki automatycznemu generowaniu treści
- Umożliwi organizację materiału w przejrzyste tematy i lekcje
- Zapewni inteligentny system powtórek uwzględniający historię nauki
- Pozwoli na obiektywną ocenę poprawności odpowiedzi z tolerancją na drobne błędy i parafrazy
- Wspiera zarówno tekstowy, jak i głosowy sposób nauki

## 3. Wymagania funkcjonalne
1. System rejestracji i logowania użytkowników
   - Rejestracja nowych użytkowników
   - Logowanie do systemu
   - Odzyskiwanie hasła
   - Zarządzanie kontem użytkownika

2. Zarządzanie tematami i lekcjami
   - Tworzenie i edycja tematów
   - Dodawanie, edycja i usuwanie lekcji w ramach tematów
   - Przeglądanie listy tematów i lekcji

3. Tworzenie i zarządzanie fiszkami
   - Wprowadzanie pytań/definicji (przednia strona fiszki)
   - Automatyczne generowanie odpowiedzi/wyjaśnień przez AI (tylna strona fiszki)
   - Akceptacja, edycja lub odrzucenie wygenerowanych fiszek
   - Zarządzanie istniejącymi fiszkami (edycja, usuwanie)

4. System nauki z fiszek
   - Wybór tematu i lekcji do nauki
   - Losowanie fiszek z uwzględnieniem historii nauki
   - Wyświetlanie przedniej strony fiszki
   - Opcja odczytania treści fiszki przez AI (w języku polskim lub angielskim)
   - Wprowadzanie odpowiedzi tekstowo lub głosowo
   - Automatyczna ocena poprawności odpowiedzi przez AI
   - Oznaczanie fiszek jako opanowane/nieopanowane

5. Integracja z API OpenAI
   - Generowanie treści fiszek
   - Rozpoznawanie i przetwarzanie mowy na tekst
   - Ocena poprawności odpowiedzi użytkownika
   - Obsługa języka polskiego i angielskiego

6. Responsywny interfejs użytkownika
   - Dostosowanie do urządzeń mobilnych i desktopowych
   - Wsparcie dla przeglądarek internetowych
   - Intuicyjna nawigacja i dostępność

## 4. Granice produktu
1. Ograniczenia funkcjonalne:
   - Aplikacja dostępna wyłącznie jako strona internetowa (brak natywnej aplikacji mobilnej)
   - Fiszki zawierają wyłącznie treści tekstowe (brak wsparcia dla obrazów, wykresów czy materiałów audio)
   - Brak możliwości współdzielenia fiszek między użytkownikami
   - Brak zaawansowanych statystyk i analiz postępów nauki
   - Brak trybu offline - aplikacja wymaga stałego połączenia z internetem

2. Ograniczenia techniczne:
   - Obsługa wyłącznie języka polskiego i angielskiego w wersji MVP
   - Możliwe ograniczenia dzienne w generowaniu i ocenie fiszek (zależne od kosztów API)
   - Konieczność dostępu do mikrofonu dla funkcji głosowych

3. Funkcje poza zakresem MVP:
   - Zaawansowane statystyki nauki
   - System współdzielenia fiszek między użytkownikami
   - Integracje z zewnętrznymi platformami edukacyjnymi
   - Natywne aplikacje mobilne
   - Rozbudowany system gamifikacji
   - Wsparcie dla większej liczby języków

## 5. Historyjki użytkowników

### US-001
- ID: US-001
- Tytuł: Rejestracja nowego użytkownika
- Opis: Jako nowy użytkownik, chcę zarejestrować się w aplikacji, podając swoje dane, aby móc korzystać z systemu fiszek.
- Kryteria akceptacji:
  - Użytkownik może wypełnić formularz rejestracyjny z polami: email, hasło, potwierdzenie hasła
  - System weryfikuje unikalność adresu email
  - System wymaga silnego hasła (min. 8 znaków, wielkie i małe litery, cyfry)
  - Po pomyślnej rejestracji użytkownik jest przenoszony do strony głównej aplikacji
  - W przypadku błędnych danych system wyświetla odpowiednie komunikaty

### US-002
- ID: US-002
- Tytuł: Logowanie użytkownika
- Opis: Jako zarejestrowany użytkownik, chcę zalogować się do systemu, aby uzyskać dostęp do moich fiszek i historii nauki.
- Kryteria akceptacji:
  - Użytkownik może wprowadzić swój email i hasło
  - System weryfikuje poprawność danych
  - Po poprawnym logowaniu użytkownik jest przenoszony do strony głównej
  - W przypadku błędnych danych system wyświetla odpowiednie komunikaty
  - Istnieje opcja "Zapomniałem hasła"

### US-003
- ID: US-003
- Tytuł: Odzyskiwanie hasła
- Opis: Jako użytkownik, który zapomniał hasła, chcę mieć możliwość zresetowania go, aby odzyskać dostęp do mojego konta.
- Kryteria akceptacji:
  - Użytkownik może wprowadzić swój adres email na stronie odzyskiwania hasła
  - System wysyła link do resetowania hasła na podany adres
  - Link jest ważny przez 24 godziny
  - Po kliknięciu w link użytkownik może ustawić nowe hasło
  - System potwierdza zmianę hasła

### US-004
- ID: US-004
- Tytuł: Tworzenie nowego tematu
- Opis: Jako zalogowany użytkownik, chcę utworzyć nowy temat, aby móc organizować moje fiszki.
- Kryteria akceptacji:
  - Użytkownik może wprowadzić nazwę i opcjonalny opis tematu
  - System weryfikuje unikalność nazwy tematu w ramach konta użytkownika
  - Po zapisaniu temat pojawia się na liście tematów użytkownika
  - Użytkownik może edytować lub usunąć utworzony temat

### US-005
- ID: US-005
- Tytuł: Dodawanie lekcji do tematu
- Opis: Jako zalogowany użytkownik, chcę dodać lekcję do istniejącego tematu, aby lepiej uporządkować moje fiszki.
- Kryteria akceptacji:
  - Użytkownik może wybrać istniejący temat
  - Użytkownik może wprowadzić nazwę i opcjonalny opis lekcji
  - System weryfikuje unikalność nazwy lekcji w ramach wybranego tematu
  - Po zapisaniu lekcja pojawia się na liście lekcji w danym temacie
  - Użytkownik może edytować lub usunąć utworzoną lekcję

### US-006
- ID: US-006
- Tytuł: Tworzenie fiszek z pomocą AI
- Opis: Jako zalogowany użytkownik, chcę wprowadzić pytania i wygenerować odpowiedzi za pomocą AI, aby szybko tworzyć kompletne fiszki.
- Kryteria akceptacji:
  - Użytkownik może wybrać temat i lekcję
  - Użytkownik może wprowadzić pytanie/definicję (przednią stronę fiszki)
  - System generuje odpowiedź/wyjaśnienie (tylną stronę fiszki) za pomocą API AI
  - Użytkownik widzi wygenerowaną odpowiedź
  - Użytkownik może zaakceptować, edytować lub odrzucić wygenerowaną odpowiedź
  - Zaakceptowana fiszka jest zapisywana w systemie

### US-007
- ID: US-007
- Tytuł: Edycja istniejącej fiszki
- Opis: Jako zalogowany użytkownik, chcę edytować istniejącą fiszkę, aby poprawić jej treść lub dostosować ją do moich potrzeb.
- Kryteria akceptacji:
  - Użytkownik może wybrać fiszkę do edycji
  - System wyświetla aktualne pytanie i odpowiedź
  - Użytkownik może zmodyfikować obie strony fiszki
  - Po zapisaniu zmian fiszka jest aktualizowana w systemie
  - Historia poprzednich odpowiedzi na tę fiszkę jest zachowana

### US-008
- ID: US-008
- Tytuł: Wybór lekcji do nauki
- Opis: Jako zalogowany użytkownik, chcę wybrać temat i lekcję, z których chcę się uczyć, aby rozpocząć powtarzanie fiszek.
- Kryteria akceptacji:
  - Użytkownik widzi listę dostępnych tematów
  - Po wybraniu tematu użytkownik widzi listę lekcji
  - System wyświetla informacje o liczbie fiszek w każdej lekcji
  - Po wybraniu lekcji użytkownik może rozpocząć naukę
  - Użytkownik widzi swoje statystyki dla wybranej lekcji (jeśli istnieją)

### US-009
- ID: US-009
- Tytuł: Nauka z fiszek - odpowiedzi tekstowe
- Opis: Jako zalogowany użytkownik, chcę zobaczyć przednią stronę fiszki i udzielić odpowiedzi tekstowej, aby sprawdzić swoją wiedzę.
- Kryteria akceptacji:
  - System wyświetla przednią stronę fiszki (pytanie)
  - Użytkownik może wprowadzić odpowiedź tekstową
  - System ocenia poprawność odpowiedzi z tolerancją na drobne błędy i parafrazy
  - Użytkownik otrzymuje informację zwrotną o poprawności odpowiedzi
  - System wyświetla prawidłową odpowiedź po udzieleniu odpowiedzi przez użytkownika
  - Użytkownik może przejść do kolejnej fiszki

### US-010
- ID: US-010
- Tytuł: Nauka z fiszek - odpowiedzi głosowe
- Opis: Jako zalogowany użytkownik, chcę odpowiedzieć głosowo na pytanie z fiszki, aby ćwiczyć wymowę i przyspieszyć proces nauki.
- Kryteria akceptacji:
  - System wyświetla przednią stronę fiszki (pytanie)
  - Użytkownik może nacisnąć przycisk nagrywania i udzielić odpowiedzi głosowej
  - System przekształca mowę na tekst
  - System ocenia poprawność przetworzonej odpowiedzi
  - Użytkownik otrzymuje informację zwrotną o poprawności odpowiedzi
  - System wyświetla prawidłową odpowiedź po udzieleniu odpowiedzi przez użytkownika
  - Użytkownik może przejść do kolejnej fiszki

### US-011
- ID: US-011
- Tytuł: Odczytanie pytania przez AI
- Opis: Jako zalogowany użytkownik, chcę odsłuchać pytanie z fiszki odczytane przez AI, aby ćwiczyć rozumienie ze słuchu.
- Kryteria akceptacji:
  - Użytkownik widzi przycisk odtwarzania dźwięku przy pytaniu
  - Po kliknięciu przycisku system odczytuje treść pytania
  - Odczyt działa zarówno dla języka polskiego, jak i angielskiego
  - Użytkownik może zatrzymać odtwarzanie
  - Użytkownik może ponownie odtworzyć pytanie

### US-012
- ID: US-012
- Tytuł: Oznaczanie fiszek jako opanowane/nieopanowane
- Opis: Jako zalogowany użytkownik, chcę oznaczać fiszki jako opanowane lub nieopanowane, aby system lepiej dostosował proces nauki.
- Kryteria akceptacji:
  - Po udzieleniu odpowiedzi użytkownik może oznaczyć fiszkę jako opanowaną lub nieopanowaną
  - System uwzględnia oznaczenie przy kolejnym losowaniu fiszek (częściej pokazuje nieopanowane)
  - Użytkownik może przeglądać listę fiszek z informacją o ich statusie
  - Użytkownik może ręcznie zmienić status opanowania fiszki z poziomu listy

### US-013
- ID: US-013
- Tytuł: Zarządzanie kontem użytkownika
- Opis: Jako zalogowany użytkownik, chcę zarządzać ustawieniami mojego konta, aby dostosować aplikację do moich potrzeb.
- Kryteria akceptacji:
  - Użytkownik może zmienić swoje hasło
  - Użytkownik może zaktualizować adres email
  - Użytkownik może ustawić preferowany język interfejsu (polski lub angielski)
  - Użytkownik może usunąć swoje konto wraz ze wszystkimi danymi
  - System wymaga potwierdzenia przed wykonaniem krytycznych operacji (np. usunięcie konta)

### US-014
- ID: US-014
- Tytuł: Wylogowanie z systemu
- Opis: Jako zalogowany użytkownik, chcę się wylogować z systemu, aby zabezpieczyć swoje konto na współdzielonym urządzeniu.
- Kryteria akceptacji:
  - Użytkownik może kliknąć przycisk wylogowania
  - Po wylogowaniu użytkownik jest przenoszony do strony logowania
  - Sesja użytkownika jest usuwana
  - Dostęp do chronionych zasobów jest blokowany po wylogowaniu

### US-015
- ID: US-015
- Tytuł: Przeglądanie postępów nauki
- Opis: Jako zalogowany użytkownik, chcę przeglądać podstawowe statystyki moich postępów, aby śledzić efektywność nauki.
- Kryteria akceptacji:
  - Użytkownik widzi liczbę opanowanych fiszek w każdej lekcji
  - Użytkownik widzi datę ostatniej nauki dla każdej lekcji
  - Użytkownik widzi liczbę sesji nauki dla każdej lekcji
  - System wyświetla podstawowy wykres postępów w czasie

## 6. Metryki sukcesu
1. Efektywność generowania fiszek:
   - Co najmniej 75% fiszek generowanych przez AI jest akceptowanych przez użytkowników bez istotnych zmian
   - Średni czas tworzenia fiszki (od wprowadzenia pytania do akceptacji odpowiedzi) nie przekracza 30 sekund

2. Zaangażowanie użytkowników:
   - Co najmniej 70% zarejestrowanych użytkowników loguje się ponownie w ciągu 7 dni od pierwszej rejestracji
   - Średnio użytkownicy spędzają minimum 15 minut dziennie na nauce z fiszek
   - Użytkownicy tworzą średnio co najmniej 10 fiszek tygodniowo

3. Dokładność oceny odpowiedzi:
   - W 90% przypadków system poprawnie ocenia odpowiedzi tekstowe (zgodnie z oceną użytkownika)
   - W 80% przypadków system poprawnie ocenia odpowiedzi głosowe (zgodnie z oceną użytkownika)

4. Wzrost bazy użytkowników:
   - Miesięczny wzrost liczby zarejestrowanych użytkowników na poziomie minimum 10%
   - Współczynnik rekomendacji (NPS) na poziomie co najmniej 40

5. Stabilność i wydajność:
   - Dostępność systemu na poziomie 99,5%
   - Średni czas odpowiedzi serwera poniżej 500ms
   - Średni czas generowania odpowiedzi przez AI poniżej 3 sekund 