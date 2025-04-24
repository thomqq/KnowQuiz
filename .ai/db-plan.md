# KnowQuiz - Schemat bazy danych PostgreSQL

## 1. Tabele

### 1.1. Profiles
```sql
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'user',
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

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Trigger do automatycznego tworzenia profilu po rejestracji użytkownika
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();
```

### 1.2. Topics
```sql
CREATE TABLE public.topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, name)
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.topics
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.3. Lessons
```sql
CREATE TABLE public.lessons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topic_id UUID NOT NULL REFERENCES public.topics(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(topic_id, name)
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.lessons
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.4. Flashcards
```sql
CREATE TABLE public.flashcards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    question TEXT NOT NULL,
    answer TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.flashcards
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.5. Learning_Status
```sql
CREATE TABLE public.learning_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    flashcard_id UUID NOT NULL REFERENCES public.flashcards(id) ON DELETE CASCADE,
    is_learned BOOLEAN NOT NULL DEFAULT false,
    last_reviewed_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, flashcard_id)
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.learning_status
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.6. Learning_Sessions
```sql
CREATE TABLE public.learning_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    lesson_id UUID NOT NULL REFERENCES public.lessons(id) ON DELETE CASCADE,
    started_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    ended_at TIMESTAMP WITH TIME ZONE,
    cards_reviewed INTEGER NOT NULL DEFAULT 0,
    cards_learned INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.learning_sessions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 1.7. OpenAI_Logs
```sql
CREATE TABLE public.openai_logs (
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

## 2. Typy danych

```sql
-- Typy wyliczeniowe
CREATE TYPE user_role AS ENUM ('user', 'admin');
```

## 3. Indeksy

```sql
-- Indeksy dla poprawy wydajności zapytań
CREATE INDEX profiles_role_idx ON public.profiles(role);
CREATE INDEX topics_user_id_idx ON public.topics(user_id);
CREATE INDEX lessons_topic_id_idx ON public.lessons(topic_id);
CREATE INDEX flashcards_lesson_id_idx ON public.flashcards(lesson_id);
CREATE INDEX learning_status_user_id_idx ON public.learning_status(user_id);
CREATE INDEX learning_status_flashcard_id_idx ON public.learning_status(flashcard_id);
CREATE INDEX learning_status_is_learned_idx ON public.learning_status(is_learned);
CREATE INDEX learning_status_last_reviewed_at_idx ON public.learning_status(last_reviewed_at);
CREATE INDEX learning_sessions_user_id_idx ON public.learning_sessions(user_id);
CREATE INDEX learning_sessions_lesson_id_idx ON public.learning_sessions(lesson_id);
CREATE INDEX openai_logs_user_id_idx ON public.openai_logs(user_id);
CREATE INDEX openai_logs_created_at_idx ON public.openai_logs(created_at);
```

## 4. Funkcje i triggery

### 4.1. Aktualizacja pola updated_at

```sql
-- Funkcja do automatycznej aktualizacji pola updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggery dla aktualizacji pola updated_at
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.topics
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.lessons
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.flashcards
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

### 4.2. Tworzenie profilu użytkownika

```sql
-- Funkcja do automatycznego tworzenia profilu po rejestracji użytkownika
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id)
    VALUES (NEW.id);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger tworzący profil po rejestracji użytkownika
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_user();
```

### 4.3. Aktualizacja roli administratora w JWT

```sql
-- Funkcja do aktualizacji roli administratora w JWT claims
CREATE OR REPLACE FUNCTION public.handle_admin_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.role = 'admin' AND (OLD.role IS NULL OR OLD.role <> 'admin') THEN
        UPDATE auth.users SET raw_app_meta_data = 
            raw_app_meta_data || json_build_object('role', 'admin')::jsonb
            WHERE id = NEW.id;
    ELSIF NEW.role = 'user' AND OLD.role = 'admin' THEN
        UPDATE auth.users SET raw_app_meta_data = 
            raw_app_meta_data - 'role'
            WHERE id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger aktualizujący JWT claims po zmianie roli
CREATE TRIGGER on_admin_role_update
AFTER UPDATE OF role ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION public.handle_admin_update();
```

### 4.4. Inicjalizacja statusu nauki dla nowej fiszki

```sql
-- Funkcja do inicjalizacji statusu nauki dla nowej fiszki
CREATE OR REPLACE FUNCTION create_learning_status_for_new_flashcard()
RETURNS TRIGGER AS $$
DECLARE
    creator_id UUID;
BEGIN
    -- Find the user_id of the topic owner
    SELECT topics.user_id INTO creator_id
    FROM public.lessons
    JOIN public.topics ON lessons.topic_id = topics.id
    WHERE lessons.id = NEW.lesson_id;
    
    -- Create learning_status entry for the creator
    INSERT INTO public.learning_status (user_id, flashcard_id)
    VALUES (creator_id, NEW.id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger tworzący status nauki po dodaniu fiszki
CREATE TRIGGER create_learning_status_after_flashcard_insert
AFTER INSERT ON public.flashcards
FOR EACH ROW
EXECUTE FUNCTION create_learning_status_for_new_flashcard();
```

### 4.5. Aktualizacja czasu ostatniego przeglądu

```sql
-- Funkcja do aktualizacji czasu ostatniego przeglądu fiszki
CREATE OR REPLACE FUNCTION update_last_reviewed_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_reviewed_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger aktualizujący czas ostatniego przeglądu
CREATE TRIGGER update_last_reviewed_at_on_learning_status
BEFORE UPDATE OF is_learned ON public.learning_status
FOR EACH ROW
EXECUTE FUNCTION update_last_reviewed_at();
```

### 4.6. Funkcja wybierająca fiszki do nauki

```sql
-- Funkcja do wybierania fiszek do nauki
CREATE OR REPLACE FUNCTION select_flashcards_for_learning(
    p_lesson_id UUID,
    p_user_id UUID,
    p_limit INTEGER DEFAULT 10
)
RETURNS TABLE (
    id UUID,
    question TEXT,
    answer TEXT,
    is_learned BOOLEAN,
    last_reviewed_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        f.id,
        f.question,
        f.answer,
        ls.is_learned,
        ls.last_reviewed_at
    FROM 
        public.flashcards f
    JOIN 
        public.learning_status ls ON f.id = ls.flashcard_id
    WHERE 
        f.lesson_id = p_lesson_id
        AND ls.user_id = p_user_id
    ORDER BY 
        ls.is_learned ASC,
        ls.last_reviewed_at ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
```

## 5. Row-Level Security (RLS)

### 5.1. Włączenie RLS dla wszystkich tabel

```sql
-- Włączenie RLS dla wszystkich tabel
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.learning_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.openai_logs ENABLE ROW LEVEL SECURITY;
```

### 5.2. Polityki RLS dla profiles

```sql
-- Polityki RLS dla tabeli profiles
CREATE POLICY "Admins can see all profiles"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Users can see their own profile"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile"
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = id);
```

### 5.3. Polityki RLS dla topics

```sql
-- Polityki RLS dla tabeli topics
CREATE POLICY "Admins can see all topics"
    ON public.topics
    FOR SELECT
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Users can see their own topics"
    ON public.topics
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own topics"
    ON public.topics
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own topics"
    ON public.topics
    FOR UPDATE
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own topics"
    ON public.topics
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);
```

### 5.4. Polityki RLS dla lessons

```sql
-- Polityki RLS dla tabeli lessons
CREATE POLICY "Admins can see all lessons"
    ON public.lessons
    FOR SELECT
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Users can see their own lessons"
    ON public.lessons
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = lessons.topic_id
            AND topics.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert lessons into their own topics"
    ON public.lessons
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = lessons.topic_id
            AND topics.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own lessons"
    ON public.lessons
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = lessons.topic_id
            AND topics.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete their own lessons"
    ON public.lessons
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.topics
            WHERE topics.id = lessons.topic_id
            AND topics.user_id = auth.uid()
        )
    );
```

### 5.5. Polityki RLS dla flashcards

```sql
-- Polityki RLS dla tabeli flashcards
CREATE POLICY "Admins can see all flashcards"
    ON public.flashcards
    FOR SELECT
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Users can see their own flashcards"
    ON public.flashcards
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.lessons
            JOIN public.topics ON lessons.topic_id = topics.id
            WHERE flashcards.lesson_id = lessons.id
            AND topics.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert flashcards into their own lessons"
    ON public.flashcards
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.lessons
            JOIN public.topics ON lessons.topic_id = topics.id
            WHERE flashcards.lesson_id = lessons.id
            AND topics.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update their own flashcards"
    ON public.flashcards
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.lessons
            JOIN public.topics ON lessons.topic_id = topics.id
            WHERE flashcards.lesson_id = lessons.id
            AND topics.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can delete their own flashcards"
    ON public.flashcards
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.lessons
            JOIN public.topics ON lessons.topic_id = topics.id
            WHERE flashcards.lesson_id = lessons.id
            AND topics.user_id = auth.uid()
        )
    );
```

### 5.6. Polityki RLS dla learning_status

```sql
-- Polityki RLS dla tabeli learning_status
CREATE POLICY "Admins can see all learning statuses"
    ON public.learning_status
    FOR SELECT
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Users can see their own learning statuses"
    ON public.learning_status
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own learning statuses"
    ON public.learning_status
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own learning statuses"
    ON public.learning_status
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own learning statuses"
    ON public.learning_status
    FOR DELETE
    TO authenticated
    USING (user_id = auth.uid());
```

### 5.7. Polityki RLS dla learning_sessions

```sql
-- Polityki RLS dla tabeli learning_sessions
CREATE POLICY "Admins can see all learning sessions"
    ON public.learning_sessions
    FOR SELECT
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Users can see their own learning sessions"
    ON public.learning_sessions
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Users can insert their own learning sessions"
    ON public.learning_sessions
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update their own learning sessions"
    ON public.learning_sessions
    FOR UPDATE
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Users can delete their own learning sessions"
    ON public.learning_sessions
    FOR DELETE
    TO authenticated
    USING (user_id = auth.uid());
```

### 5.8. Polityki RLS dla openai_logs

```sql
-- Polityki RLS dla tabeli openai_logs
CREATE POLICY "Admins can see all openai logs"
    ON public.openai_logs
    FOR SELECT
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Users can see their own openai logs"
    ON public.openai_logs
    FOR SELECT
    TO authenticated
    USING (user_id = auth.uid());

CREATE POLICY "Only admins can delete openai logs"
    ON public.openai_logs
    FOR DELETE
    TO authenticated
    USING (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Users can insert their own openai logs"
    ON public.openai_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (user_id = auth.uid());
```

## 6. Relacje

### Relacje jeden-do-wielu (1:N):
1. User (1) -> Topics (N): Jeden użytkownik może mieć wiele tematów
2. Topic (1) -> Lessons (N): Jeden temat może zawierać wiele lekcji
3. Lesson (1) -> Flashcards (N): Jedna lekcja może zawierać wiele fiszek
4. User (1) -> Learning_Sessions (N): Jeden użytkownik może mieć wiele sesji nauki
5. Lesson (1) -> Learning_Sessions (N): Jedna lekcja może być przedmiotem wielu sesji nauki
6. User (1) -> OpenAI_Logs (N): Jeden użytkownik może generować wiele logów API

### Relacje jeden-do-jednego (1:1):
1. User-Flashcard -> Learning_Status: Dla każdej kombinacji użytkownika i fiszki istnieje jeden rekord statusu nauki

## 7. Ograniczenia i walidacje

W schemacie bazy danych zastosowano następujące ograniczenia:

1. Powiązanie profiles z auth.users poprzez klucz obcy
2. Unikalność nazwy tematu dla użytkownika: `UNIQUE(user_id, name)` w tabeli `topics`
3. Unikalność nazwy lekcji dla tematu: `UNIQUE(topic_id, name)` w tabeli `lessons`
4. Unikalność kombinacji użytkownika i fiszki w statusie nauki: `UNIQUE(user_id, flashcard_id)` w tabeli `learning_status`
5. Walidacja roli użytkownika poprzez typ enum: `user_role` z wartościami 'user' i 'admin'
6. Klucze obce z opcją `ON DELETE CASCADE` zapewniające integralność referencyjną

## 8. Dodatkowe uwagi

1. Schemat wykorzystuje UUID jako klucze główne, co zapewnia lepsze bezpieczeństwo i łatwiejszą synchronizację danych.
2. Uwierzytelnianie użytkowników jest zarządzane przez Supabase Auth.
3. Row-Level Security (RLS) zapewnia, że użytkownicy mają dostęp tylko do własnych danych, a administratorzy do wszystkich.
4. Automatyczne triggery zapewniają:
   - Aktualizację pola updated_at przy każdej modyfikacji rekordu
   - Tworzenie profilu po rejestracji użytkownika
   - Aktualizację JWT claims przy zmianie roli użytkownika
   - Inicjalizację statusu nauki dla nowych fiszek
   - Aktualizację czasu ostatniego przeglądu fiszki
5. Indeksy na często używanych polach zapewniają wysoką wydajność zapytań.
6. System został zaprojektowany z myślą o skalowalności i bezpieczeństwie danych.
``` 