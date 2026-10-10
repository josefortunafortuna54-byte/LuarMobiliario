-- Migration 012: Marcações sem conta (visitantes)
-- O acesso com login/criação de conta foi removido.
-- Um visitante pode agendar uma visita indicando apenas nome e telefone.
--   1. user_id passa a ser opcional em bookings (marcações de visitantes)
--   2. Policy RLS permite que um utilizador anónimo crie uma marcação
--      sem user_id (guarda apenas user_name e user_phone)

ALTER TABLE bookings ALTER COLUMN user_id DROP NOT NULL;

DROP POLICY IF EXISTS "Bookings: authenticated insert" ON bookings;
DROP POLICY IF EXISTS "Bookings: insert own or guest" ON bookings;
CREATE POLICY "Bookings: insert own or guest" ON bookings
  FOR INSERT WITH CHECK (
    (auth.role() = 'anon' AND user_id IS NULL)
    OR (auth.uid() = user_id)
  );