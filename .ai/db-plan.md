# KnowQuiz - Schemat bazy danych PostgreSQL

## 1. Tabele

### 1.1. Profiles
```sql
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
    preferred_language VARCHAR(10) DEFAULT 'pl' CHECK (preferred_language IN ('pl', 'en')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Trigger do automatycznej aktualizacji updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger do automatycznego tworzenia profilu po rejestracji użytkownika
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION handle_new_user();
```

### 1.2. Topics
```sql
CREATE TABLE topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, name)
);

CREATE TRIGGER update_topics_updated_at
BEFORE UPDATE ON topics
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.3. Lessons
```sql
CREATE TABLE lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topic_id UUID NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(topic_id, name)
);

CREATE TRIGGER update_lessons_updated_at
BEFORE UPDATE ON lessons
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.4. Flashcards
```sql
CREATE TABLE flashcards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    language VARCHAR(10) DEFAULT 'pl' CHECK (language IN ('pl', 'en')),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_flashcards_updated_at
BEFORE UPDATE ON flashcards
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.5. Learning_Status
```sql
CREATE TABLE learning_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    flashcard_id UUID NOT NULL REFERENCES flashcards(id) ON DELETE CASCADE,
    is_learned BOOLEAN NOT NULL DEFAULT false,
    last_reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, flashcard_id)
);

CREATE TRIGGER update_learning_status_updated_at
BEFORE UPDATE ON learning_status
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.6. Learning_Sessions
```sql
CREATE TABLE learning_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES lessons(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    cards_reviewed INTEGER NOT NULL DEFAULT 0,
    cards_learned INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER update_learning_sessions_updated_at
BEFORE UPDATE ON learning_sessions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.7. Session_Details
```sql
CREATE TABLE session_details (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL REFERENCES learning_sessions(id) ON DELETE CASCADE,
    flashcard_id UUID NOT NULL REFERENCES flashcards(id) ON DELETE CASCADE,
    user_answer TEXT,
    is_correct BOOLEAN,
    marked_as_learned BOOLEAN,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
```

### 1.8. OpenAI_Logs
```sql
CREATE TABLE openai_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    operation_type VARCHAR(50) NOT NULL CHECK (operation_type IN ('generate_answer', 'check_answer', 'text_to_speech', 'speech_to_text')),
    request_data JSONB NOT NULL,
    response_data JSONB,
    tokens_used INTEGER,
    cost DECIMAL(10, 6),
    status VARCHAR(20) NOT NULL CHECK (status IN ('success', 'error', 'timeout')),
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);
```

## 2. Indeksy

```sql
-- Indeksy dla tabeli profiles
CREATE INDEX idx_profiles_role ON profiles(role);

-- Indeksy dla tabeli topics
CREATE INDEX idx_topics_user_id ON topics(user_id);
CREATE INDEX idx_topics_name ON topics(name);
CREATE INDEX idx_topics_created_at ON topics(created_at);

-- Indeksy dla tabeli lessons
CREATE INDEX idx_lessons_topic_id ON lessons(topic_id);
CREATE INDEX idx_lessons_name ON lessons(name);
CREATE INDEX idx_lessons_created_at ON lessons(created_at);

-- Indeksy dla tabeli flashcards
CREATE INDEX idx_flashcards_lesson_id ON flashcards(lesson_id);
CREATE INDEX idx_flashcards_created_at ON flashcards(created_at);
CREATE INDEX idx_flashcards_language ON flashcards(language);

-- Indeksy dla tabeli learning_status
CREATE INDEX idx_learning_status_user_id ON learning_status(user_id);
CREATE INDEX idx_learning_status_flashcard_id ON learning_status(flashcard_id);
CREATE INDEX idx_learning_status_is_learned ON learning_status(is_learned);
CREATE INDEX idx_learning_status_last_reviewed_at ON learning_status(last_reviewed_at);
CREATE INDEX idx_learning_status_user_id_is_learned ON learning_status(user_id, is_learned);

-- Indeksy dla tabeli learning_sessions
CREATE INDEX idx_learning_sessions_user_id ON learning_sessions(user_id);
CREATE INDEX idx_learning_sessions_lesson_id ON learning_sessions(lesson_id);
CREATE INDEX idx_learning_sessions_started_at ON learning_sessions(started_at);

-- Indeksy dla tabeli session_details
CREATE INDEX idx_session_details_session_id ON session_details(session_id);
CREATE INDEX idx_session_details_flashcard_id ON session_details(flashcard_id);
CREATE INDEX idx_session_details_is_correct ON session_details(is_correct);

-- Indeksy dla tabeli openai_logs
CREATE INDEX idx_openai_logs_user_id ON openai_logs(user_id);
CREATE INDEX idx_openai_logs_operation_type ON openai_logs(operation_type);
CREATE INDEX idx_openai_logs_created_at ON openai_logs(created_at);
CREATE INDEX idx_openai_logs_status ON openai_logs(status);
```

## 3. Row-Level Security (RLS)

```sql
-- Włączenie RLS dla tabel
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE learning_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_details ENABLE ROW LEVEL SECURITY;
ALTER TABLE openai_logs ENABLE ROW LEVEL SECURITY;

-- Polityki dla tabeli profiles
CREATE POLICY profiles_self_access ON profiles
    FOR ALL
    TO authenticated
    USING (id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Polityki dla tabeli topics
CREATE POLICY topics_user_access ON topics
    FOR ALL
    TO authenticated
    USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Polityki dla tabeli lessons
CREATE POLICY lessons_user_access ON lessons
    FOR ALL
    TO authenticated
    USING (EXISTS (SELECT 1 FROM topics WHERE topics.id = topic_id AND (topics.user_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))));

-- Polityki dla tabeli flashcards
CREATE POLICY flashcards_user_access ON flashcards
    FOR ALL
    TO authenticated
    USING (EXISTS (
        SELECT 1 FROM lessons 
        JOIN topics ON lessons.topic_id = topics.id 
        WHERE flashcards.lesson_id = lessons.id AND (topics.user_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
    ));

-- Polityki dla tabeli learning_status
CREATE POLICY learning_status_user_access ON learning_status
    FOR ALL
    TO authenticated
    USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Polityki dla tabeli learning_sessions
CREATE POLICY learning_sessions_user_access ON learning_sessions
    FOR ALL
    TO authenticated
    USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));

-- Polityki dla tabeli session_details
CREATE POLICY session_details_user_access ON session_details
    FOR ALL
    TO authenticated
    USING (EXISTS (
        SELECT 1 FROM learning_sessions 
        WHERE session_details.session_id = learning_sessions.id AND (learning_sessions.user_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'))
    ));

-- Polityki dla tabeli openai_logs
CREATE POLICY openai_logs_user_access ON openai_logs
    FOR ALL
    TO authenticated
    USING (user_id = auth.uid() OR EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'));
```

## 4. Przydatne widoki

```sql
-- Widok do statystyk użytkownika dla każdej lekcji
CREATE VIEW user_lesson_stats AS
SELECT 
    u.id AS user_id,
    l.id AS lesson_id,
    t.id AS topic_id,
    t.name AS topic_name,
    l.name AS lesson_name,
    COUNT(f.id) AS total_flashcards,
    COUNT(ls.id) FILTER (WHERE ls.is_learned = true) AS learned_flashcards,
    MAX(ls.last_reviewed_at) AS last_reviewed_at,
    COUNT(DISTINCT s.id) AS total_sessions,
    SUM(s.cards_reviewed) AS total_cards_reviewed
FROM 
    auth.users u
JOIN 
    topics t ON t.user_id = u.id
JOIN 
    lessons l ON l.topic_id = t.id
LEFT JOIN 
    flashcards f ON f.lesson_id = l.id
LEFT JOIN 
    learning_status ls ON ls.flashcard_id = f.id AND ls.user_id = u.id
LEFT JOIN 
    learning_sessions s ON s.lesson_id = l.id AND s.user_id = u.id
GROUP BY 
    u.id, l.id, t.id;

-- Widok do wyboru fiszek do nauki (uwzględniający algorytm)
CREATE VIEW flashcards_to_review AS
SELECT 
    ls.user_id,
    f.id AS flashcard_id,
    f.question,
    f.answer,
    f.lesson_id,
    l.topic_id,
    ls.is_learned,
    ls.last_reviewed_at,
    CASE 
        WHEN ls.is_learned = false THEN 1
        WHEN ls.last_reviewed_at IS NULL THEN 2
        ELSE EXTRACT(EPOCH FROM (NOW() - ls.last_reviewed_at)) / 86400 -- dni od ostatniego przeglądu
    END AS priority_score
FROM 
    flashcards f
JOIN 
    lessons l ON f.lesson_id = l.id
JOIN 
    learning_status ls ON ls.flashcard_id = f.id
WHERE 
    ls.is_learned = false OR ls.last_reviewed_at < NOW() - INTERVAL '7 days'
ORDER BY 
    ls.user_id, priority_score DESC;

-- Zmaterializowany widok dla raportów administratora
CREATE MATERIALIZED VIEW admin_usage_stats AS
SELECT 
    DATE_TRUNC('day', u.created_at) AS day,
    COUNT(DISTINCT u.id) AS new_users,
    COUNT(DISTINCT s.id) AS learning_sessions,
    SUM(s.cards_reviewed) AS total_cards_reviewed,
    SUM(s.cards_learned) AS total_cards_learned,
    COUNT(DISTINCT t.id) AS new_topics,
    COUNT(DISTINCT l.id) AS new_lessons,
    COUNT(DISTINCT f.id) AS new_flashcards,
    COUNT(DISTINCT o.id) AS openai_api_calls,
    SUM(o.tokens_used) AS total_tokens_used,
    SUM(o.cost) AS total_api_cost
FROM 
    auth.users u
LEFT JOIN 
    learning_sessions s ON s.user_id = u.id AND DATE_TRUNC('day', s.created_at) = DATE_TRUNC('day', u.created_at)
LEFT JOIN 
    topics t ON t.user_id = u.id AND DATE_TRUNC('day', t.created_at) = DATE_TRUNC('day', u.created_at)
LEFT JOIN 
    lessons l ON l.topic_id = t.id AND DATE_TRUNC('day', l.created_at) = DATE_TRUNC('day', u.created_at)
LEFT JOIN 
    flashcards f ON f.lesson_id = l.id AND DATE_TRUNC('day', f.created_at) = DATE_TRUNC('day', u.created_at)
LEFT JOIN 
    openai_logs o ON o.user_id = u.id AND DATE_TRUNC('day', o.created_at) = DATE_TRUNC('day', u.created_at)
GROUP BY 
    DATE_TRUNC('day', u.created_at)
ORDER BY 
    DATE_TRUNC('day', u.created_at);

-- Indeks dla zmaterializowanego widoku
CREATE UNIQUE INDEX idx_admin_usage_stats_day ON admin_usage_stats(day);
```

## 5. Funkcje i procedury

```sql
-- Funkcja do inicjowania statusu nauki dla nowej fiszki
CREATE OR REPLACE FUNCTION initialize_learning_status() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO learning_status (user_id, flashcard_id, is_learned, last_reviewed_at)
    SELECT 
        u.id,
        NEW.id,
        false,
        NULL
    FROM 
        auth.users u
    ON CONFLICT (user_id, flashcard_id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger dla nowych fiszek
CREATE TRIGGER new_flashcard_learning_status
AFTER INSERT ON flashcards
FOR EACH ROW
EXECUTE FUNCTION initialize_learning_status();

-- Funkcja do zakończenia sesji nauki
CREATE OR REPLACE FUNCTION end_learning_session(session_id UUID)
RETURNS VOID AS $$
DECLARE
    learned_count INTEGER;
BEGIN
    -- Ustawienie czasu zakończenia sesji
    UPDATE learning_sessions
    SET 
        ended_at = NOW(),
        cards_learned = (
            SELECT COUNT(*) 
            FROM session_details 
            WHERE session_id = end_learning_session.session_id AND marked_as_learned = true
        )
    WHERE id = session_id;
END;
$$ LANGUAGE plpgsql;

-- Funkcja do wyboru fiszek do nauki
CREATE OR REPLACE FUNCTION get_flashcards_for_learning(
    p_user_id UUID,
    p_lesson_id UUID,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    flashcard_id UUID,
    question TEXT,
    answer TEXT,
    is_learned BOOLEAN,
    last_reviewed_at TIMESTAMP WITH TIME ZONE,
    priority_score FLOAT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.question,
        f.answer,
        ls.is_learned,
        ls.last_reviewed_at,
        CASE 
            WHEN ls.is_learned = false THEN 1
            WHEN ls.last_reviewed_at IS NULL THEN 2
            ELSE EXTRACT(EPOCH FROM (NOW() - ls.last_reviewed_at)) / 86400 -- dni od ostatniego przeglądu
        END AS priority_score
    FROM 
        flashcards f
    JOIN 
        learning_status ls ON ls.flashcard_id = f.id AND ls.user_id = p_user_id
    WHERE 
        f.lesson_id = p_lesson_id
    ORDER BY 
        priority_score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
```

## 6. Relacje

### Relacje jeden-do-wielu (1:N):
1. User (1) -> Topics (N): Jeden użytkownik może mieć wiele tematów
2. Topic (1) -> Lessons (N): Jeden temat może zawierać wiele lekcji
3. Lesson (1) -> Flashcards (N): Jedna lekcja może zawierać wiele fiszek
4. User (1) -> Learning_Sessions (N): Jeden użytkownik może mieć wiele sesji nauki
5. Lesson (1) -> Learning_Sessions (N): Jedna lekcja może być przedmiotem wielu sesji nauki
6. Learning_Session (1) -> Session_Details (N): Jedna sesja nauki ma wiele szczegółów
7. User (1) -> OpenAI_Logs (N): Jeden użytkownik może generować wiele logów API

### Relacje wiele-do-jednego (N:1):
1. Wszystkie relacje jeden-do-wielu są również relacjami wiele-do-jednego z perspektywy tabeli "wielu"

### Relacje jeden-do-jednego (1:1):
1. User-Flashcard -> Learning_Status: Dla każdej kombinacji użytkownika i fiszki istnieje jeden rekord statusu nauki

## 7. Ograniczenia i walidacje

Ograniczenia są zdefiniowane w definicjach tabel, ale warto podkreślić:

1. Unikalność adresu email użytkownika: `UNIQUE(email)` w tabeli `users`
2. Unikalność nazwy tematu dla użytkownika: `UNIQUE(user_id, name)` w tabeli `topics`
3. Unikalność nazwy lekcji dla tematu: `UNIQUE(topic_id, name)` w tabeli `lessons`
4. Unikalność kombinacji użytkownika i fiszki w statusie nauki: `UNIQUE(user_id, flashcard_id)` w tabeli `learning_status`
5. Walidacja roli użytkownika: `CHECK (role IN ('user', 'admin'))` w tabeli `users`
6. Walidacja typu operacji w logach OpenAI: `CHECK (operation_type IN ('generate_answer', 'check_answer', 'text_to_speech', 'speech_to_text'))` w tabeli `openai_logs`
7. Walidacja statusu operacji w logach OpenAI: `CHECK (status IN ('success', 'error', 'timeout'))` w tabeli `openai_logs`
8. Walidacja języka dla fiszek: `CHECK (language IN ('pl', 'en'))` w tabeli `flashcards`

## 8. Dodatkowe uwagi

1. Schemat wykorzystuje UUID jako klucze główne, co jest dobrą praktyką dla aplikacji webowych i zapewnia lepsze bezpieczeństwo.
2. Uwierzytelnianie użytkowników jest zarządzane przez Supabase Auth, który dostarcza gotowy system rejestracji, logowania i zarządzania kontami.
3. Dodatkowe informacje o użytkownikach są przechowywane w tabeli profiles, która jest połączona z tabelą auth.users.
4. Row-Level Security (RLS) jest skonfigurowane tak, aby użytkownicy mieli dostęp tylko do swoich danych, a administratorzy do wszystkich.
5. Indeksy są zdefiniowane dla kolumn często używanych w zapytaniach, co poprawia wydajność.
6. Triggery automatycznie aktualizują pole `updated_at` przy każdej modyfikacji rekordu oraz tworzą profil użytkownika po rejestracji.
7. Widoki i funkcje ułatwiają implementację złożonej logiki biznesowej, takiej jak algorytm wyboru fiszek do nauki.
8. Zmaterializowane widoki są użyte do generowania raportów dla administratorów, co pozwala na efektywne uzyskiwanie statystyk bez obciążania bazy danych.
``` 