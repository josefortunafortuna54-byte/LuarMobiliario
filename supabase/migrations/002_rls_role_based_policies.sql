-- ── RLS Policies v2: Role-based access control ─────────────────────
-- Drop existing overly-permissive policies and replace with granular ones

-- ════════════════════════════════════════════════════════════════════
-- Helper: get current user's role
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.get_user_role()
RETURNS user_role AS $$
  SELECT role FROM public.users WHERE id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ════════════════════════════════════════════════════════════════════
-- USERS
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Users read for anon" ON users;
DROP POLICY IF EXISTS "Users all for authenticated" ON users;

-- Anyone can read basic user info (for agent profiles, etc.)
CREATE POLICY "Users: public read" ON users
  FOR SELECT USING (true);

-- Users can update only their own profile
CREATE POLICY "Users: update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Admins can do everything with users
CREATE POLICY "Users: admin full access" ON users
  FOR ALL USING (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════
-- CATEGORIES
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Categories read for anon" ON categories;
DROP POLICY IF EXISTS "Categories all for authenticated" ON categories;

CREATE POLICY "Categories: public read" ON categories
  FOR SELECT USING (true);

CREATE POLICY "Categories: admin manage" ON categories
  FOR ALL USING (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════
-- LOCATIONS
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Locations read for anon" ON locations;
DROP POLICY IF EXISTS "Locations all for authenticated" ON locations;

CREATE POLICY "Locations: public read" ON locations
  FOR SELECT USING (true);

CREATE POLICY "Locations: admin manage" ON locations
  FOR ALL USING (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════
-- PROPERTIES
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Properties read for anon" ON properties;
DROP POLICY IF EXISTS "Properties all for authenticated" ON properties;

-- Anyone can browse available properties
CREATE POLICY "Properties: public read" ON properties
  FOR SELECT USING (true);

-- Agents and admins can create properties
CREATE POLICY "Properties: agents and admins insert" ON properties
  FOR INSERT WITH CHECK (
    public.get_user_role() IN ('agent', 'admin')
  );

-- Agents can update their own properties, admins can update any
CREATE POLICY "Properties: update own or admin" ON properties
  FOR UPDATE USING (
    auth.uid() = agent_id OR public.get_user_role() = 'admin'
  );

-- Admins can delete any property
CREATE POLICY "Properties: admin delete" ON properties
  FOR DELETE USING (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════
-- LANDS
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Lands read for anon" ON lands;
DROP POLICY IF EXISTS "Lands all for authenticated" ON lands;

CREATE POLICY "Lands: public read" ON lands
  FOR SELECT USING (true);

CREATE POLICY "Lands: agents and admins insert" ON lands
  FOR INSERT WITH CHECK (
    public.get_user_role() IN ('agent', 'admin')
  );

CREATE POLICY "Lands: update own or admin" ON lands
  FOR UPDATE USING (
    auth.uid() = agent_id OR public.get_user_role() = 'admin'
  );

CREATE POLICY "Lands: admin delete" ON lands
  FOR DELETE USING (public.get_user_role() = 'admin');

-- ════════════════════════════════════════════════════════════════════
-- PROPERTY IMAGES
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Property images read for anon" ON property_images;
DROP POLICY IF EXISTS "Property images all for authenticated" ON property_images;

CREATE POLICY "Property images: public read" ON property_images
  FOR SELECT USING (true);

CREATE POLICY "Property images: agents and admins manage" ON property_images
  FOR ALL USING (
    public.get_user_role() IN ('agent', 'admin')
  );

-- ════════════════════════════════════════════════════════════════════
-- LAND IMAGES
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Land images read for anon" ON land_images;
DROP POLICY IF EXISTS "Land images all for authenticated" ON land_images;

CREATE POLICY "Land images: public read" ON land_images
  FOR SELECT USING (true);

CREATE POLICY "Land images: agents and admins manage" ON land_images
  FOR ALL USING (
    public.get_user_role() IN ('agent', 'admin')
  );

-- ════════════════════════════════════════════════════════════════════
-- FAVORITES
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Favorites read for anon" ON favorites;
DROP POLICY IF EXISTS "Favorites all for authenticated" ON favorites;

-- Users can read their own favorites
CREATE POLICY "Favorites: read own" ON favorites
  FOR SELECT USING (auth.uid() = user_id);

-- Users can add/remove their own favorites
CREATE POLICY "Favorites: insert own" ON favorites
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Favorites: delete own" ON favorites
  FOR DELETE USING (auth.uid() = user_id);

-- ════════════════════════════════════════════════════════════════════
-- BOOKINGS
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Bookings read for anon" ON bookings;
DROP POLICY IF EXISTS "Bookings all for authenticated" ON bookings;

-- Users can read their own bookings; agents/admins can read bookings for their properties
CREATE POLICY "Bookings: read own or agent" ON bookings
  FOR SELECT USING (
    auth.uid() = user_id
    OR public.get_user_role() IN ('agent', 'admin')
  );

-- Authenticated users can create bookings
CREATE POLICY "Bookings: authenticated insert" ON bookings
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Users can update their own bookings; agents/admins can update status
CREATE POLICY "Bookings: update own" ON bookings
  FOR UPDATE USING (
    auth.uid() = user_id
    OR public.get_user_role() IN ('agent', 'admin')
  );

-- ════════════════════════════════════════════════════════════════════
-- MESSAGES
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Messages read for anon" ON messages;
DROP POLICY IF EXISTS "Messages all for authenticated" ON messages;

-- Users can read messages they sent or received
CREATE POLICY "Messages: read own" ON messages
  FOR SELECT USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
  );

-- Authenticated users can send messages
CREATE POLICY "Messages: authenticated insert" ON messages
  FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Users can mark their own messages as read
CREATE POLICY "Messages: update own" ON messages
  FOR UPDATE USING (
    auth.uid() = sender_id OR auth.uid() = receiver_id
  );

-- ════════════════════════════════════════════════════════════════════
-- NOTIFICATIONS
-- ════════════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS "Notifications read for anon" ON notifications;
DROP POLICY IF EXISTS "Notifications all for authenticated" ON notifications;

-- Users can read their own notifications
CREATE POLICY "Notifications: read own" ON notifications
  FOR SELECT USING (auth.uid() = user_id);

-- System (admin/service role) can create notifications
CREATE POLICY "Notifications: admin insert" ON notifications
  FOR INSERT WITH CHECK (public.get_user_role() = 'admin');

-- Users can mark their own notifications as read
CREATE POLICY "Notifications: update own" ON notifications
  FOR UPDATE USING (auth.uid() = user_id);
