-- Secretario IA (SEC-IA-001, F0): tablas de chat, memoria y preferencias.
--
-- Patrón: mismas convenciones que el resto del esquema (fecha_registro /
-- ultima_actualizacion para LWW del cliente, server_updated_at por trigger
-- como cursor de pull incremental). RLS más estricta que el patrón
-- empresa-wide: los chats y preferencias son personales (usuario_id =
-- auth.uid()); las memorias con scope 'business' son visibles a la empresa.

-- ---------------------------------------------------------------------------
-- Tablas
-- ---------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS public.chat_sessions (
  id uuid PRIMARY KEY,
  empresa_id uuid NOT NULL REFERENCES public.empresa(id) ON DELETE CASCADE,
  usuario_id uuid NOT NULL REFERENCES public.usuario(id) ON DELETE CASCADE,
  title text NOT NULL,
  summary text,
  status text NOT NULL DEFAULT 'active',
  last_message_at timestamptz NOT NULL DEFAULT now(),
  message_count integer NOT NULL DEFAULT 0,
  metadata jsonb,
  fecha_registro timestamptz NOT NULL DEFAULT now(),
  ultima_actualizacion timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.chat_messages (
  id uuid PRIMARY KEY,
  session_id uuid NOT NULL REFERENCES public.chat_sessions(id) ON DELETE CASCADE,
  empresa_id uuid NOT NULL REFERENCES public.empresa(id) ON DELETE CASCADE,
  usuario_id uuid NOT NULL REFERENCES public.usuario(id) ON DELETE CASCADE,
  role text NOT NULL,
  content text NOT NULL,
  content_type text NOT NULL DEFAULT 'text',
  draft_id uuid,
  seq integer NOT NULL,
  fecha_registro timestamptz NOT NULL DEFAULT now(),
  ultima_actualizacion timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.ai_memories (
  id uuid PRIMARY KEY,
  empresa_id uuid NOT NULL REFERENCES public.empresa(id) ON DELETE CASCADE,
  usuario_id uuid NOT NULL REFERENCES public.usuario(id) ON DELETE CASCADE,
  scope text NOT NULL DEFAULT 'user',
  category text NOT NULL,
  content text NOT NULL,
  source_session_id uuid,
  confidence double precision NOT NULL DEFAULT 1.0,
  is_active boolean NOT NULL DEFAULT true,
  last_used_at timestamptz,
  fecha_registro timestamptz NOT NULL DEFAULT now(),
  ultima_actualizacion timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.ai_preferences (
  id uuid PRIMARY KEY,
  empresa_id uuid NOT NULL REFERENCES public.empresa(id) ON DELETE CASCADE,
  usuario_id uuid NOT NULL REFERENCES public.usuario(id) ON DELETE CASCADE,
  tone text NOT NULL DEFAULT 'neutral',
  verbosity text NOT NULL DEFAULT 'concise',
  default_bodega_id uuid REFERENCES public.bodega(id) ON DELETE SET NULL,
  voice_enabled boolean NOT NULL DEFAULT true,
  auto_read_responses boolean NOT NULL DEFAULT false,
  tts_rate double precision NOT NULL DEFAULT 1.0,
  confirm_before_execute boolean NOT NULL DEFAULT true,
  extra jsonb,
  fecha_registro timestamptz NOT NULL DEFAULT now(),
  ultima_actualizacion timestamptz NOT NULL DEFAULT now(),
  server_updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT unique_ai_preferences_usuario UNIQUE (empresa_id, usuario_id)
);

-- ---------------------------------------------------------------------------
-- Índices
-- ---------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_chat_sessions_usuario_actividad
  ON public.chat_sessions (usuario_id, last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_session_seq
  ON public.chat_messages (session_id, seq);
CREATE INDEX IF NOT EXISTS idx_ai_memories_usuario_activas
  ON public.ai_memories (usuario_id, is_active);

-- ---------------------------------------------------------------------------
-- Trigger server_updated_at (cursor de pull) + índices del cursor
-- ---------------------------------------------------------------------------

DO $$
DECLARE
  t text;
  tablas text[] := ARRAY[
    'chat_sessions', 'chat_messages', 'ai_memories', 'ai_preferences'
  ];
BEGIN
  FOREACH t IN ARRAY tablas LOOP
    EXECUTE format(
      'CREATE INDEX IF NOT EXISTS idx_%s_server_updated_at ON public.%I (server_updated_at)',
      t, t
    );
    EXECUTE format('DROP TRIGGER IF EXISTS trg_server_updated_at ON public.%I', t);
    EXECUTE format(
      'CREATE TRIGGER trg_server_updated_at BEFORE INSERT OR UPDATE ON public.%I FOR EACH ROW EXECUTE FUNCTION public.set_server_updated_at()',
      t
    );
  END LOOP;
END;
$$;

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

ALTER TABLE public.chat_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_memories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS chat_sessions_owner ON public.chat_sessions;
CREATE POLICY chat_sessions_owner ON public.chat_sessions
  FOR ALL
  USING (empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid())
  WITH CHECK (empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid());

DROP POLICY IF EXISTS chat_messages_owner ON public.chat_messages;
CREATE POLICY chat_messages_owner ON public.chat_messages
  FOR ALL
  USING (empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid())
  WITH CHECK (empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid());

DROP POLICY IF EXISTS ai_memories_owner_or_business ON public.ai_memories;
CREATE POLICY ai_memories_owner_or_business ON public.ai_memories
  FOR ALL
  USING (
    empresa_id = get_mi_empresa_id()
    AND (usuario_id = auth.uid() OR scope = 'business')
  )
  WITH CHECK (empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid());

DROP POLICY IF EXISTS ai_preferences_owner ON public.ai_preferences;
CREATE POLICY ai_preferences_owner ON public.ai_preferences
  FOR ALL
  USING (empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid())
  WITH CHECK (empresa_id = get_mi_empresa_id() AND usuario_id = auth.uid());

NOTIFY pgrst, 'reload schema';
