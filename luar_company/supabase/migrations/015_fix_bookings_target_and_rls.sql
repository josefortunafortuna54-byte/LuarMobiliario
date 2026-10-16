-- Migration 015: corrige agendamentos de terrenos e a gestão pelo admin
-- Problemas resolvidos:
--   1. A app permite agendar uma visita a um TERRENO, mas `bookings` só tinha
--      `property_id` (FK -> properties). Inserir um terreno violava a FK e a
--      marcação nunca era criada. Passa a existir `land_id`.
--   2. `property_id` passa a ser opcional; uma marcação aponta exatamente para
--      um imóvel OU um terreno (CHECK).
--   3. A policy de UPDATE (migration 007) exigia `auth.uid() = user_id` no
--      WITH CHECK, impedindo agentes/admins de confirmar/cancelar marcações de
--      terceiros. Corrigida.
--   4. A policy de SELECT não deixava o visitante anónimo ler a marcação que
--      acabou de criar (INSERT ... RETURNING falhava). Permitido para
--      marcações ainda sem user_id.

-- ════════════════════════════════════════════════════════════════════════
-- 1. TERRENOS NAS MARCAÇÕES
-- ════════════════════════════════════════════════════════════════════════

ALTER TABLE bookings
  ADD COLUMN IF NOT EXISTS land_id UUID REFERENCES lands(id) ON DELETE CASCADE;

ALTER TABLE bookings ALTER COLUMN property_id DROP NOT NULL;

ALTER TABLE bookings DROP CONSTRAINT IF EXISTS chk_booking_target;
ALTER TABLE bookings ADD CONSTRAINT chk_booking_target CHECK (
  ((property_id IS NOT NULL)::int + (land_id IS NOT NULL)::int) = 1
);

CREATE INDEX IF NOT EXISTS idx_bookings_land_id ON bookings(land_id);

-- ════════════════════════════════════════════════════════════════════════
-- 2. SELECT — visitante lê a marcação que acabou de criar
-- ════════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Bookings: read own or agent" ON bookings;
CREATE POLICY "Bookings: read own or agent" ON bookings
  FOR SELECT USING (
    auth.uid() = user_id
    OR (auth.role() = 'anon' AND user_id IS NULL)
    OR public.get_user_role() IN ('agent', 'admin')
  );

-- ════════════════════════════════════════════════════════════════════════
-- 3. UPDATE — agentes/admins gerem marcações de terceiros
-- ════════════════════════════════════════════════════════════════════════

-- Nota: as policies RLS não expõem OLD/NEW. Em USING as colunas referem-se à
-- linha existente; em WITH CHECK, aos novos valores. Assim, o cliente só pode
-- passar de 'pending' (USING) para 'cancelled' (WITH CHECK); agentes/admins
-- podem alterar qualquer estado.
DROP POLICY IF EXISTS "Bookings: update own" ON bookings;
CREATE POLICY "Bookings: update own" ON bookings
  FOR UPDATE USING (
    public.get_user_role() IN ('agent', 'admin')
    OR (auth.uid() = user_id AND status = 'pending')
  )
  WITH CHECK (
    public.get_user_role() IN ('agent', 'admin')
    OR (auth.uid() = user_id AND status = 'cancelled')
  );
